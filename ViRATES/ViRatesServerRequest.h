//
//  ViRatesServerRequest.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViRatesServerRequest : NSObject

- (NSDictionary*) parameters;
- (BOOL) isValidateParameter;


@end
