//
//  SensorDataManager.h
//  SpecialNumber
//
//  Created by Yuuki Nishiyama on 2014/12/27.
//  Copyright (c) 2014年 tetujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorDataManager : NSObject

@property (strong, nonatomic) NSMutableDictionary *map; // All of data are saved as String
@property (strong, nonatomic) NSMutableDictionary *source; // All of data are saved as own original object format

- (void) setSensorDataString:(NSString *)str;

- (void)setData:(NSObject *)value withKey:(NSString *)key;
- (NSString *) getDataByKey: (NSString *)key;

- (NSArray *) getKeys;

@end
