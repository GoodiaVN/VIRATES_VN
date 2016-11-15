//
//  CloseButton.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/26.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagView.h"

@interface CloseButton : UIButton

@property (weak,nonatomic) TagView *tagView;
@property (nonatomic) CGFloat iconSize;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor *lineColor;
@end
