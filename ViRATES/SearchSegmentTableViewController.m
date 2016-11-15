//
//  SearchSegmentTableViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/02.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "SearchSegmentTableViewController.h"
#import "SearchSegmentTableViewCell.h"
#import "HMSegmentedControl.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SearchSegmentTableViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) HMSegmentedControl *segmentedControl;

@end

@implementation SearchSegmentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *segmentMenu = [NSArray arrayWithObjects:@"新着", @"人気", nil];

    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:segmentMenu];
    self.segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.selectionIndicatorHeight = 3.0f;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.00];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName: [UIColor colorWithRed:0.122 green:0.122 blue:0.122 alpha:1.00]};

    self.segmentedControl.titleTextAttributes = attributes;
    [self.segmentedControl addTarget:self action:@selector(selectedSegmentedControl) forControlEvents:UIControlEventValueChanged];

    self.tableView.tableHeaderView = self.segmentedControl;
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchSegmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchSegmentTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectedSegmentedControl {
    NSLog(@"selectedSegmentedControl %ld",self.segmentedControl.selectedSegmentIndex);

}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.articleArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchSegmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchSegmentTableViewCell"];
    Article *article  = [self.articleArray objectAtIndex:indexPath.row];
    [cell.articleImageView sd_setImageWithURL:[NSURL URLWithString:article.thumbnail]];
    cell.articleTitleLabel.text = article.title;
    cell.dateLabel.text = article.date;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Article *article  = [self.articleArray objectAtIndex:indexPath.row];
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchSegmentTable:didSelectedArticle:withAllArticleArray:)]) {
        [self.delegate searchSegmentTable:self.tableView didSelectedArticle:article withAllArticleArray:self.articleArray];
    }
}

- (void)loadTableView {
    [self.tableView reloadData];
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
