//
//  SenbayFormatCompressor.h
//  QRCodeTest
//
//  Created by Yuuki Nishiyama on 2015/03/20.
//  Copyright (c) 2015年 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseX.h"

@interface SenbayFormat : NSObject

- (NSString *) encode:(NSString *)text baseNumber:(int)baseNumber;
- (NSString *) decode:(NSString *)text baseNumber:(int)baseNumber;
@end
