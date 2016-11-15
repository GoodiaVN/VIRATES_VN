//
//  ArticleCategory.h
//  ViRATES
//
//  Created by PTMBR-020 on 2016/08/26.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleCategory : NSObject
- (instancetype)initWithDictionaryData:(NSDictionary *)dicData;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSNumber *sort;
@property (strong, nonatomic) NSString *name;
@end
