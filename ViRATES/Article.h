//
//  Article.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/14.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject
- (instancetype)initWithDictionaryData:(NSDictionary *)dicData;

@property (strong, nonatomic) id ad;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *iv;
@property (strong, nonatomic) NSNumber *top;
@property (strong, nonatomic) NSString *impurl;

@property (strong, nonatomic) NSNumber *aId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSNumber *commentCount;
@property (strong, nonatomic) NSNumber *totalLike;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSNumber *sponsored;

@property (nonatomic) BOOL isFavorite;

@end
