//
//  ArticleTableViewHeader.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/04.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXLabel/FXLabel.h>

@interface ArticleTableViewHeader : UIView
@property (weak, nonatomic) IBOutlet FXLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
+ (instancetype)view;
@end
