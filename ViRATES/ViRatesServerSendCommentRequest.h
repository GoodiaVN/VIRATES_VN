//
//  ViRatesServerSendCommentRequest.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/20.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ViRatesServerRequest.h"

@interface ViRatesServerSendCommentRequest : ViRatesServerRequest
@property (nonatomic) NSString *comment;
@property (nonatomic) NSString *aId;
@end
