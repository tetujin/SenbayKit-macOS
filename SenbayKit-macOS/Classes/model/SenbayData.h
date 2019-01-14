//
//  SenbayData.h
//  SenbayDesktop
//
//  Created by Yuuki Nishiyama on 5/10/16.
//  Copyright © 2016 Yuuki NISHIYAMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "SensorDataManager.h"

@interface SenbayData : NSObject

- (instancetype) initWithString:(NSString *)content;
- (instancetype) initWithString:(NSString *)content
                          baseX:(int)baseNumber;
- (instancetype) initWithString:(NSString *)content
                  encryptionKey:(NSString* )encryptionKey
                          baseX:(int)baseNumber;

@property (strong, nonatomic, readonly) NSString *baseString;

@property SensorDataManager * sdManager;

@property int baseNumber;

@property (strong, nonatomic) NSString * time;
@property (strong, nonatomic) NSNumber * unixtime;
@property (strong, nonatomic) NSNumber * longitude;
@property (strong, nonatomic) NSNumber * latitude;
@property (strong, nonatomic) NSNumber * altitude;
@property (strong, nonatomic) NSNumber * speed;
@property (strong, nonatomic) NSNumber * airPressure;
@property (strong, nonatomic) NSNumber * brightness;
@property (strong, nonatomic) NSNumber * temperature;
@property (strong, nonatomic) NSNumber * humidity;
@property (strong, nonatomic) NSNumber * windSpeed;
@property (strong, nonatomic) NSNumber * hb;
@property (strong, nonatomic) NSNumber * accx;
@property (strong, nonatomic) NSNumber * accy;
@property (strong, nonatomic) NSNumber * accz;
@property (strong, nonatomic) NSNumber * gyrox;
@property (strong, nonatomic) NSNumber * gyroy;
@property (strong, nonatomic) NSNumber * gyroz;
@property (strong, nonatomic) NSNumber * magx;
@property (strong, nonatomic) NSNumber * magy;
@property (strong, nonatomic) NSNumber * magz;
@property (strong, nonatomic) NSNumber * heading;
@property (strong, nonatomic) NSString * weather;
@property (strong, nonatomic) NSImage  * weatherImage;

@property (strong, nonatomic) NSNumber * colorValue;

@property (strong, nonatomic) NSString * tag;

@property (strong, nonatomic) NSString * errorMessage;
// @property (strong, nonatomic) NSString * rawData;

// - (void) setCSVHeader:(NSString *)headerLine;
- (void) updateCSVHeader;
- (NSString *) getCSVHeaderLine;
- (NSString *) getCSVDataLine;
- (NSString *) getJSONFormatLine;

- (NSArray *) getAllKeys;
- (NSString *) getSensorDataWithKey:(NSString *) key;


@end
