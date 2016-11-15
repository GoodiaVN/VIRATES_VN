//
//  FavoriteActionViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FavoriteActionViewDelegate <NSObject>
@optional
- (void)favoriteActionTableViewDidSelectedAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface FavoriteActionViewController : UIViewController

@property (nonatomic, assign) id<FavoriteActionViewDelegate> delegate;

@end
