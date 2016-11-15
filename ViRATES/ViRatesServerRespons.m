//
//  ViRatesServerRespons.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ViRatesServerRespons.h"

@implementation ViRatesServerRespons

+ (NSDictionary *)convertObjectToJsonDictionary:(id)object {
    NSString *tmpData = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
    tmpData = [tmpData stringByReplacingOccurrencesOfString:@"<html>" withString:@""];
    tmpData = [tmpData stringByReplacingOccurrencesOfString:@"</html>" withString:@""];
    NSData *d = [tmpData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;

    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingAllowFragments error:&error];

    if(error) {
        return nil;
    } else {
        return jsonDict;
    }
}
- (void) setResponsObject:(NSDictionary*)responsObject {

}

@end
