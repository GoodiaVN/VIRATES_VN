//
//  Article.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/14.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "Article.h"

@implementation Article
- (instancetype)initWithDictionaryData:(NSDictionary *)dicData {
    self = [super init];
    if(self){
        self.ad             = nil;
        self.count          = @0;
        self.iv             = @0;
        self.top            = @0;
        self.impurl         = @"";

        self.commentCount   = @0;
        self.totalLike      = @0;
        self.isFavorite     = NO;
        self.date           = @"";
        self.sponsored      = @0;

        if( dicData[@"ad"] && ![dicData[@"ad"] isEqual:[NSNull null]] ) {
            self.ad = dicData[@"ad"];
        }

        if( dicData[@"count"] && ![dicData[@"count"] isEqual:[NSNull null]] ) {
            self.count = [NSNumber numberWithInteger:[dicData[@"count"] integerValue]];
        }

        if( dicData[@"iv"] && ![dicData[@"iv"] isEqual:[NSNull null]] ) {
            self.iv = [NSNumber numberWithInteger:[dicData[@"iv"] integerValue]];
        }

        if( dicData[@"top"] && ![dicData[@"top"] isEqual:[NSNull null]] ) {
            self.top = [NSNumber numberWithInteger:[dicData[@"top"] integerValue]];
        }

        if( dicData[@"impurl"] && ![dicData[@"impurl"] isEqual:[NSNull null]] ) {
            self.impurl = dicData[@"impurl"];
        }

        if( dicData[@"id"] && ![dicData[@"id"] isEqual:[NSNull null]] ) {
            self.aId = [NSNumber numberWithInteger:[dicData[@"id"] integerValue]];
        }

        if( dicData[@"title"] && ![dicData[@"title"] isEqual:[NSNull null]] ) {
            self.title = dicData[@"title"];
        }

        if( dicData[@"thumbnail"] && ![dicData[@"thumbnail"] isEqual:[NSNull null]] ) {
            self.thumbnail = dicData[@"thumbnail"];
        }

        if( dicData[@"link"] && ![dicData[@"link"] isEqual:[NSNull null]] ) {
            self.link = dicData[@"link"];
        }

        if( dicData[@"comment_count"] && ![dicData[@"comment_count"] isEqual:[NSNull null]] ) {
            self.commentCount = [NSNumber numberWithInteger:[dicData[@"comment_count"] integerValue]];
        }

        if( dicData[@"like"] && ![dicData[@"like"] isEqual:[NSNull null]] ) {
            self.totalLike = [NSNumber numberWithInteger:[dicData[@"like"] integerValue]];
        }

        if(dicData[@"date"] && ![dicData[@"date"] isEqual:[NSNull null]] ) {
            self.date = dicData[@"date"];
        }

        if( dicData[@"sponsored"] && ![dicData[@"sponsored"] isEqual:[NSNull null]] ) {
            self.sponsored = [NSNumber numberWithInteger:[dicData[@"sponsored"] integerValue]];
        }

    }
    return self;
}
@end
