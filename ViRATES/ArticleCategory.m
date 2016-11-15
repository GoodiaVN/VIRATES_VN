//
//  ArticleCategory.m
//  ViRATES
//
//  Created by PTMBR-020 on 2016/08/26.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleCategory.h"

@implementation ArticleCategory
- (instancetype)initWithDictionaryData:(NSDictionary *)dicData {
    self = [super init];
    if(self){
        if( dicData[@"link"] && ![dicData[@"link"] isEqual:[NSNull null]] ) {
            self.link = dicData[@"link"];
        }
        if( dicData[@"sort"] && ![dicData[@"sort"] isEqual:[NSNull null]] ) {
            self.sort = [NSNumber numberWithInteger:[dicData[@"sort"] integerValue]];
        }
        if( dicData[@"name"] && ![dicData[@"name"] isEqual:[NSNull null]] ) {
            self.name = dicData[@"name"];
        }
    }
    return self;
}

@end
