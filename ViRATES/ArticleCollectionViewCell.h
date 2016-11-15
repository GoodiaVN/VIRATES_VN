//
//  ArticleCollectionViewCell.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/03.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *articleLabelImageView;
@property (weak, nonatomic) IBOutlet UILabel *articleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCommentLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (weak, nonatomic) IBOutlet UILabel *adLabel;


@end
