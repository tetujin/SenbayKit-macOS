//
//  SensorDataManager.m
//  SpecialNumber
//
//  Created by Yuuki Nishiyama on 2014/12/27.
//  Copyright (c) 2014年 tetujin. All rights reserved.
//

#import "SensorDataManager.h"

@implementation SensorDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _map = [NSMutableDictionary dictionary];
        _source = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)setSensorDataString:(NSString *)str
{
    [_map removeAllObjects];//初期化
    NSArray* array = [str componentsSeparatedByString:@","];
    //NSMutableString* newText = [[NSMutableString alloc] init];
    for (int i=0; i<[array count]; i++) {
        NSArray* contents = [[array objectAtIndex:i] componentsSeparatedByString:@":"];
        if([contents count] > 1){
            NSString* key = [contents objectAtIndex:0];
            NSString* value = [contents objectAtIndex:1];
            // NSLog(@"%@ : %@", key, value);
            //NSLog(@"%@",[value substringFromIndex:1]);
            
            // string
            if([[value substringToIndex:1] isEqualToString:@"'"] && [[value substringFromIndex:1] isEqualToString:@"'"]){
                NSMutableString *mvalue = [[NSMutableString alloc] initWithString:value.copy];
                [mvalue deleteCharactersInRange:NSMakeRange(0, 1)];
                [mvalue deleteCharactersInRange:NSMakeRange([mvalue length]-1, 1)];
                value = mvalue;
                _map[key] = value;
                _source[key] = value;
            // string 2
            }else if([[value substringToIndex:1] isEqualToString:@"'"] ){
                if (contents.count > 1) {
                    NSMutableString * mValue = [[NSMutableString alloc] init];
                    for (int i=1; i<contents.count; i++) {
                        [mValue appendString:[contents objectAtIndex:i]];
                    }
                    [mValue deleteCharactersInRange:NSMakeRange(0, 1)];
                    [mValue deleteCharactersInRange:NSMakeRange([mValue length]-1, 1)];
                    value = mValue.description;
                    // NSLog(@"%@",value);
                }
                _map[key] = value;
                _source[key] = value;
            // number
            }else{
                // value = @"";
                _map[key] = value;
                _source[key] = @(value.doubleValue);
            }
            
        }else{
            NSLog(@"error");
        }
    }
}


- (void)setData:(NSObject *)value withKey:(NSString *)key
{
    if(value!=nil && key != nil){
        [_map setObject:value.debugDescription forKey:key];
        [_source setObject:value forKey:key];
    }
}

- (NSString *)getDataByKey:(NSString *)key
{
    NSString* value = _map[key];
    if(value!=nil){
        return _map[key];
    }else{
        return @"";
    }
}

- (NSArray *)getKeys {
    if(_map != nil){
        return [_map allKeys];
    }else{
        return @[];
    }
}


@end
