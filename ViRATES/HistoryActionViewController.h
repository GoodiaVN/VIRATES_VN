//
//  HistoryActionViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HistoryActionViewDelegate <NSObject>
@optional
- (void)historyActionTableViewDidSelectedAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface HistoryActionViewController : UIViewController

@property (nonatomic, assign) id<HistoryActionViewDelegate> delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil disableAddFavorite:(BOOL)disableAddFavorite;
@end
