//
//  SettingViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "SettingViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <iOS-Slide-Menu/SlideNavigationController.h>

@interface SettingViewController () <SlideNavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menuTitleArray;
@property (strong, nonatomic) NSString *appVersionString;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"設定";
    self.appVersionString = @"1.1.9";
    self.menuTitleArray = [[NSArray alloc] initWithObjects:@"プッシュ設定",
                           @"バージョン情報",
                           @"お問い合わせ",nil];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
     [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 2;
    } else if (section == 1) {
        return 1;
    }

    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }

    if(indexPath.section == 0 ) {
        cell.textLabel.text = self.menuTitleArray[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [theSwitch setOn:NO];
        [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = theSwitch;
        if(indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = self.appVersionString;
            cell.accessoryView = nil;
        }
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = self.menuTitleArray[[self.menuTitleArray count]-1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1) {
        [self sendMail];
    }
}

-(void)sendMail {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setToRecipients:@[@"contact@virates.com"]];
    [picker setSubject:@"「ViRATES」への問い合わせ"];
    NSString *body = [NSString stringWithFormat:@"Version:%@\nOS Ver:%.1f\n\n内容：", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[UIDevice currentDevice] systemVersion] floatValue]];
    [picker setMessageBody:body isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];

}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchChanged:(UISwitch *)sender {
    NSLog(@"%@",sender.on ? @"ON" : @"OFF");
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
