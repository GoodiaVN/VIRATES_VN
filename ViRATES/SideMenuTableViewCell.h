//
//  SideMenuTableViewCell.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/06/30.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *leftBarView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *menuLabel;

- (void)setSelectedCellView:(NSString *)imageName;
- (void)setUnSelectCellView:(NSString *)imageName;
@end
