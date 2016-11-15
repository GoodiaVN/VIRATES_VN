//
//  SearchSegmentTableViewCell.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/02.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchSegmentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *articleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
