//
//  ArticleTableViewCell.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/04.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *articleTextLabel;

@end
