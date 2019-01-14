//
//  SpecialNumber3.h
//  QRCodeTest
//
//  Created by Yuuki Nishiyama on 2015/03/20.
//  Copyright (c) 2015年 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseX : NSObject

- (NSString *) encodeBaseX:(int)shinsu
                 longValue:(long)value;

- (NSString *) encodeBaseX:(int)shinsu
               doubleValue:(double)value;

- (long) decodeLongBaseX:(int)shinsu
                   value:(NSString *)valueStr;

- (double) decodeDoubleBaseX:(int)shinsu
                       value:(NSString *)valueStr;



- (void) initTable;


@end
