//
//  ArticleActionTableViewCell.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleActionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *articleTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCommentLabel;

@end
