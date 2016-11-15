//
//  FavoriteActionViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "FavoriteActionViewController.h"
#import "PopoverActionTableViewCell.h"

@interface FavoriteActionViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *actionTitle;
@end

@implementation FavoriteActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    self.actionTitle = [[NSArray alloc] initWithObjects:@"お気に入りから削除",@"キャンセル", nil];

    [self.tableView registerNib:[UINib nibWithNibName:@"PopoverActionTableViewCell" bundle:nil] forCellReuseIdentifier:@"PopoverActionTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.actionTitle count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopoverActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopoverActionTableViewCell"];
    cell.actionTextLabel.text = self.actionTitle[indexPath.row];
    UIImage *image;
    if( indexPath.row == 0 ) {
        image = [UIImage imageNamed:@"icon_del"];
    } else {
        image = [UIImage imageNamed:@"icon_cancel"];
    }
    cell.actionImageView.image = image;
    cell.actionTextLabel.textColor = [UIColor colorWithRed:0.231 green:0.231 blue:0.231 alpha:1.00];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self dismissViewControllerAnimated:YES completion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(favoriteActionTableViewDidSelectedAtIndexPath:)]) {
            [self.delegate favoriteActionTableViewDidSelectedAtIndexPath:indexPath];
        }
    }];
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
