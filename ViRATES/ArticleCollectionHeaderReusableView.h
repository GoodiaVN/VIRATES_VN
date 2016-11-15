//
//  ArticleCollectionHeaderReusableView.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/02.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXLabel/FXLabel.h>
@interface ArticleCollectionHeaderReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet FXLabel *titleLabel;
@property (weak, nonatomic) IBOutlet FXLabel *totalCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;

@end
