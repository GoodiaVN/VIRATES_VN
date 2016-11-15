//
//  HistoryActionViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "HistoryActionViewController.h"
#import "PopoverActionTableViewCell.h"

@interface HistoryActionViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *actionTitle;
@property (nonatomic) BOOL disableAddFavorite;
@end

@implementation HistoryActionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil disableAddFavorite:(BOOL)disableAddFavorite {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.disableAddFavorite = disableAddFavorite;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    self.actionTitle = [[NSArray alloc] initWithObjects:@"閲覧履歴から削除",@"お気に入りに追加",@"キャンセル", nil];

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
    } else if (indexPath.row == 1) {
        image = [UIImage imageNamed:@"icon_favorite_off"];
    } else {
        image = [UIImage imageNamed:@"icon_cancel"];
    }
    cell.actionImageView.image = image;
    if(indexPath.row == 1 && self.disableAddFavorite) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
         cell.actionTextLabel.textColor = [UIColor colorWithRed:0.231 green:0.231 blue:0.231 alpha:0.6];
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.userInteractionEnabled = YES;
        cell.actionTextLabel.textColor = [UIColor colorWithRed:0.231 green:0.231 blue:0.231 alpha:1.00];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self dismissViewControllerAnimated:YES completion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(historyActionTableViewDidSelectedAtIndexPath:)]) {
            [self.delegate historyActionTableViewDidSelectedAtIndexPath:indexPath];
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
