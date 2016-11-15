//
//  ActionButtonView.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/10/15.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionButtonView : UIView
@property (weak, nonatomic) IBOutlet UIButton *actionbutton;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

+ (instancetype)view;
@end
