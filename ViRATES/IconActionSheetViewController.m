//
//  IconActionSheetViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/03.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "IconActionSheetViewController.h"
#import "IconActionSheetTableViewCell.h"


@implementation IconActionMenu
-(instancetype)initWithImage:(UIImage *)image menuTitle:(NSString *)menuTitle {
    self = [super init];
    if(self) {
        self.iconImage = image;
        self.menuTitle = menuTitle;
    }
    return self;
}
@end

@interface IconActionSheetViewController () <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableConstraintTop;

@property (strong, nonatomic) UIView *rootView;
@property (strong, nonatomic) NSMutableArray *menuList;

@property (nonatomic, readwrite) BOOL isShowing;

@end

@implementation IconActionSheetViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                       rootView:(UIView *)rootView {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.rootView = rootView;
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBackgroundView:)];
        tapGesture.delegate = self;
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.menuList = [[NSMutableArray alloc] init];
    self.tableConstraintTop.constant = self.rootView.frame.size.height;
    [self.tableView registerNib:[UINib nibWithNibName:@"IconActionSheetTableViewCell" bundle:nil] forCellReuseIdentifier:@"IconActionSheetTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void)addIconAction:(IconActionMenu *)iconAction {
    [self.menuList addObject:iconAction];
    self.tableConstraintHeight.constant = [self.menuList count] * 60.0f;
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IconActionSheetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IconActionSheetTableViewCell" forIndexPath:indexPath];

    IconActionMenu *menu = [self.menuList objectAtIndex:indexPath.row];
    cell.iconImageView.image = menu.iconImage;
    cell.titleLabel.text = menu.menuTitle;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(actionSheet:didSelectMenuAtIndexPath:)]){
        [self.delegate actionSheet:self didSelectMenuAtIndexPath:indexPath];
    }
}


#pragma mark - 

- (void)showMenu {
    self.isShowing = YES;
    CGRect rootFrame = self.rootView.frame;
    rootFrame.origin.y = 0;
    self.view.frame = rootFrame;
    CGRect menuFrame = self.tableView.frame;
    menuFrame.origin.y = self.view.frame.size.height - menuFrame.size.height;
    self.tableConstraintTop.constant = menuFrame.origin.y;
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
    CGRect menuFrame = self.tableView.frame;
    menuFrame.origin.y += menuFrame.size.height;
    self.tableConstraintTop.constant = menuFrame.origin.y;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                        [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.view.frame = rootFrame;
                     }];

}


- (void)handleTapBackgroundView:(UITapGestureRecognizer *)sender {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didTapBackgroundActionSheet:)]){
        [self.delegate didTapBackgroundActionSheet:self];
    }
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
