//
//  SideMenuTableViewCell.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/06/30.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "SideMenuTableViewCell.h"

@implementation SideMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelectedCellView:(NSString *)imageName {
    self.leftBarView.hidden = NO;
    self.iconImageView.image = [UIImage imageNamed:imageName];
    self.contentView.backgroundColor = [UIColor colorWithRed:0.275 green:0.275 blue:0.275 alpha:1.00];
}

- (void)setUnSelectCellView:(NSString *)imageName {
    self.leftBarView.hidden = YES;
    self.iconImageView.image = [UIImage imageNamed:imageName];
    self.contentView.backgroundColor = [UIColor colorWithRed:0.220 green:0.220 blue:0.220 alpha:1.00];
}

@end
