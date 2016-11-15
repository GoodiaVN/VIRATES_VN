//
//  ViRatesServerSendCommentRequest.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/20.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ViRatesServerSendCommentRequest.h"

@implementation ViRatesServerSendCommentRequest
- (NSDictionary*) parameters{
    return @{ @"id": self.aId,
              @"comment": self.comment,
              };
}

@end
