//
//  SenbayData.m
//  SenbayDesktop
//
//  Created by Yuuki Nishiyama on 5/10/16.
//  Copyright © 2016 Yuuki NISHIYAMA. All rights reserved.
//

#import "SenbayData.h"
#import "SenbayFormat.h"
#import "SenbayFormat.h"

#import <CommonCrypto/CommonCryptor.h>

@implementation SenbayData{
    SenbayFormat * senbayFormat;
    NSMutableString * csvHeader;
    NSMutableArray *csvKeys;
}

- (instancetype)initWithString:(NSString *)content{
    return [self initWithString:content baseX:121];
}

- (instancetype)initWithString:(NSString *)content baseX:(int)baseNumber{
    return [self initWithString:content encryptionKey:nil baseX:baseNumber];
}

- (instancetype)initWithString:(NSString *)content encryptionKey:(NSString *)encryptionKey baseX:(int)baseNumber{
    self = [super init];
    if (self != nil) {
        _baseString = @"";
        _time = @"";
        _unixtime  = @0;
        _longitude = @0;
        _latitude  = @0;
        _altitude  = @0;
        _speed     = @0;
        _airPressure = @0;
        _brightness  = @0;
        _temperature = @0;
        _humidity    = @0;
        _windSpeed   = @0;
        _hb      = @0;
        _accx    = @0;
        _accy    = @0;
        _accz    = @0;
        _gyrox   = @0;
        _gyroy   = @0;
        _gyroz   = @0;
        _magx    = @0;
        _magy    = @0;
        _magz    = @0;
        _heading = @0;
        
        _colorValue = @0;
        
        _errorMessage = @"";
        
        _tag = @"";

        _baseNumber = baseNumber;
        senbayFormat = [[SenbayFormat alloc] init];
        _sdManager = [[SensorDataManager alloc] init];
        [self setDataWithString:content encryptionKey:encryptionKey];
        
        csvHeader = [[NSMutableString alloc] init];
        csvKeys   = [[NSMutableArray alloc] init];
        [self updateCSVHeader];
    }
    return self;
}

- (NSString *) getCSVHeaderLine {
    return csvHeader;
}

- (void) updateCSVHeader{
    csvHeader = [[NSMutableString alloc] init];
    csvKeys = [[NSMutableArray alloc] init];
    // Set timestamp
    [csvKeys addObject:@"TIME"];
    [csvHeader appendFormat:@"TIME,"];
    // Sort keys
    NSArray * tempKeys = [[_sdManager getKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in tempKeys) {
        // Add target keys to csvKeys unless TIME key.
        if([key isNotEqualTo:@"TIME"]){
            [csvHeader appendFormat:@"%@,",key];
            [csvKeys addObject:key];
        }
    }
    [csvHeader appendString:@"\n"];
}

- (NSString *) getCSVDataLine {
    NSMutableString* line = [[NSMutableString alloc] init];
    for (NSString *key in csvKeys ) {
        [line appendFormat:@"%@,",[_sdManager getDataByKey:key]];
    }
    [line appendString:@"\n"];
    return line;
}

- (NSString *)getJSONFormatLine{
    NSString * json = @"[]";
    if(_sdManager.source != nil){
        NSData *data = [NSJSONSerialization dataWithJSONObject:_sdManager.source options:0 error:nil];
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
    }
    return json;
}


- (NSString *) getSensorDataWithKey:(NSString *) key{
    return [_sdManager getDataByKey:key];
}

- (void) setDataWithString:(NSString *)content encryptionKey:(NSString *)encryptionKey{
    _baseString = content;
    
    NSMutableString * qrcode = [[NSMutableString alloc] initWithString:content];
    
    if([qrcode hasPrefix:@"T"] || [qrcode hasPrefix:@"0"] || [qrcode hasPrefix:@"V"]){
    
        if([qrcode hasPrefix:@"V"]){
            
            NSArray* array = [qrcode componentsSeparatedByString:@","];
            NSArray* content = [[array objectAtIndex:0] componentsSeparatedByString:@":"];
            NSString* version = [content objectAtIndex:1];
            
            if ([version isEqualToString:@"3"]){ //圧縮無しの場合
                _baseString = qrcode;
                // NSLog(@"no compression (version 3)");
            }else if([version isEqualToString:@"4"]){ //圧縮ありの場合
                _baseString = [senbayFormat decode:qrcode baseNumber:_baseNumber];
                // NSLog(@"compression (version 4)");
            }else if([version isEqualToString:@"5"]){ //圧縮無しの暗号化
                // NSRange range = [qrcode rangeOfString:@"," options:NSBackwardsSearch];
                // [qrcode deleteCharactersInRange:range];
                [qrcode deleteCharactersInRange:NSMakeRange(0, 4)];
                // NSLog(@"Before: %@", qrcode);
                _baseString = [self decodeBlowfish:qrcode withKey:encryptionKey iv:nil];
                // NSLog(@"After: %@", qrcode);
                if([_baseString length] == 0){
                    _errorMessage = @"Your password is maybe wrong. Please check it again.";
                }
            }else if([version isEqualToString:@"6"]){ //圧縮ありの暗号化
                // NSLog(@"Behellofore: %@", qrcode);
                [qrcode deleteCharactersInRange:NSMakeRange(0, 4)];
                // NSLog(@"After:  %@",qrcode);
                NSString * decodedStr = [self decodeBlowfish:qrcode withKey:encryptionKey iv:nil];
                _baseString = [senbayFormat decode:decodedStr baseNumber:_baseNumber];
                if([_baseString length] == 0){
                    _errorMessage = @"Your password is maybe wrong. Please check it again.";
                }
            }else{
                // NSLog(@"This is unsupported version of QR-code format!!");
                _errorMessage = @"This Senbay Format is not supported on Senbay Studio. Please update your Senbay Studio via Mac AppStore.";
            }
        }else if([qrcode hasPrefix:@"0"]){//圧縮ありの場合
            SenbayFormat * compQR = [[SenbayFormat alloc] init];
            _baseString = [compQR decode:qrcode baseNumber:121];
            // NSLog(@"compression (version 2)");
        }else{
            _baseString = qrcode;//圧縮無しの場合
            // NSLog(@"compression (version 1)");
        }
        
        //-- Set Content --
        [_sdManager setSensorDataString:[_baseString copy]];
        
        // _rawData = _baseString;
        
        // time
        NSString *timeStr = [_sdManager getDataByKey:@"TIME"];
        _unixtime = @([timeStr doubleValue]);
        NSDate *nsdate = [NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY/MM/dd"];
        NSString *date = [formatter stringFromDate:nsdate];
        [formatter setDateFormat:@"hh:mm:ss"];
        NSString *time = [formatter stringFromDate:nsdate];
        _time = [NSString stringWithFormat:@"%@ %@",date, time];
    
        // acc
        _accx = @([[_sdManager getDataByKey:@"ACCX"] doubleValue]);
        _accy = @([[_sdManager getDataByKey:@"ACCY"] doubleValue]);
        _accz = @([[_sdManager getDataByKey:@"ACCZ"] doubleValue]);
        
        // gyro
        _gyrox = @([[_sdManager getDataByKey:@"YAW"] doubleValue]);
        _gyroy = @([[_sdManager getDataByKey:@"ROLL"] doubleValue]);
        _gyroz = @([[_sdManager getDataByKey:@"PITC"] doubleValue]);
        
        // mag
        _magx = @([[_sdManager getDataByKey:@"MAGX"] doubleValue]);
        _magy = @([[_sdManager getDataByKey:@"MAGY"] doubleValue]);
        _magz = @([[_sdManager getDataByKey:@"MAGZ"] doubleValue]);
    
        // location
        _longitude = @([[_sdManager getDataByKey:@"LONG"] doubleValue]);
        _latitude = @([[_sdManager getDataByKey:@"LATI"] doubleValue]);
        
        // altitude
        _altitude = @([[_sdManager getDataByKey:@"ALTI"] doubleValue]);
        
        // speed (km/h)
        double doubleSpeed = [[_sdManager getDataByKey:@"SPEE"] doubleValue];
        _speed = @(doubleSpeed*3600/1000);
        
        // air pressure (hPa)
        double doublePressure = [[_sdManager getDataByKey:@"AIRP"] doubleValue];
        _airPressure = @(doublePressure*10);
        
        // brightness (0-1)
        _brightness = @([[_sdManager getDataByKey:@"BRIG"] doubleValue]);
        
        // humidity (0-100%)
        _humidity = @([[_sdManager getDataByKey:@"HUMI"] doubleValue]);
        
        // wind spee
        _windSpeed = @([[_sdManager getDataByKey:@"WIND"] doubleValue]);
        
        // temperature
        _temperature = @([[_sdManager getDataByKey:@"TEMP"] doubleValue]);
        
        //heading (0-360)
        _heading = @([[_sdManager getDataByKey:@"HEAD"] doubleValue]);
        
        // heart rate
        NSString *htbt = [_sdManager getDataByKey:@"HTBT"];
        if([htbt length] == 0){
            htbt = [_sdManager getDataByKey:@"HEAT"];
        }
        _hb = @([htbt doubleValue]);
    
        // weather image
        @autoreleasepool {
            _weatherImage = [self getWeatherImage:[_sdManager getDataByKey:@"WEAT"]];
        }
    
    }else{
        @try {
            NSArray *array = [qrcode componentsSeparatedByString:@","];
            if([array count]>8){
                _longitude = @([[array objectAtIndex:8] doubleValue]);
                _latitude  = @([[array objectAtIndex:9] doubleValue]);
                
                NSArray * timeArray = [[array objectAtIndex:1] componentsSeparatedByString:@" "];
                _time = [NSString stringWithFormat:@"%@ %@",[timeArray objectAtIndex:0], [[timeArray objectAtIndex:1] substringToIndex:8]];
                
                _accx = @([[array objectAtIndex:2] doubleValue]);
                _accy = @([[array objectAtIndex:3] doubleValue]);
                _accz = @([[array objectAtIndex:4] doubleValue]);
                _gyrox = @([[array objectAtIndex:5] doubleValue]);
                _gyroy = @([[array objectAtIndex:6] doubleValue]);
                _gyroz = @([[array objectAtIndex:7] doubleValue]);
                _heading = @([[array objectAtIndex:12] doubleValue]);
                
                NSString *unixtimestamp = [array objectAtIndex:0];
                if(unixtimestamp != nil){
                    [_sdManager setData:@(unixtimestamp.floatValue) withKey:@"TIME"];
                }
                // acc
                [_sdManager setData:_accx withKey:@"ACCX"];
                [_sdManager setData:_accy withKey:@"ACCY"];
                [_sdManager setData:_accz withKey:@"ACCZ"];
                
                // gyro
                [_sdManager setData:_gyrox withKey:@"YAW"];
                [_sdManager setData:_gyroy withKey:@"ROLL"];
                [_sdManager setData:_gyroz withKey:@"PITC"];

                // mag
//                [sdManager setData:_magx.stringValue withKey:@"MAGX"];
//                [sdManager setData:_magy.stringValue withKey:@"MAGY"];
//                [sdManager setData:_magz.stringValue withKey:@"MAGZ"];

                // location
                [_sdManager setData:_longitude withKey:@"LONG"];
                [_sdManager setData:_latitude withKey:@"LATI"];


                // speed (km/h)
                // [sdManager setData:_speed.stringValue withKey:@"SPEE"];
                
                // air pressure (hPa)
                //[sdManager setData:_airPressure.stringValue withKey:@"AIRP"];

//                // brightness (0-1)
//                [sdManager setData: withKey:@"BRIG"] doubleValue]);
//                
//                // humidity (0-100%)
//                [sdManager setData: withKey:@"HUMI"] doubleValue]);
//                
//                // wind spee
//                [sdManager setData: withKey:@"WIND"] doubleValue]);
//                
//                // temperature
//                [sdManager setData: withKey:@"TEMP"] doubleValue]);
//                
//                //heading (0-360)
                [_sdManager setData:_heading withKey:@"HEAD"];

            }
            if([array count]>16 ){
                if([[array objectAtIndex:16] length] > 7){
                    _altitude = @([[[array objectAtIndex:16] substringToIndex:6] doubleValue]);
                }else{
                    _altitude = @([[array objectAtIndex:16] doubleValue]);
                }
                [_sdManager setData:_altitude withKey:@"ALTI"];
            }
            if([array count]>17){
                _hb = @([[array objectAtIndex:17] doubleValue]);
                [_sdManager setData:_hb withKey:@"HTBT"];
            }else{
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }

}


- (NSImage *)getWeatherImage:(NSString *)weatherType
{
    NSString * weatherImageName = @"";
    if ([weatherType isEqualToString:@"Clear"]) {
        weatherImageName = @"clear sky";
        //}else if ([weatherType isEqualToString:@"Clouds"]){
        //    weatherImageName = @"few clouds";
    } else if ([weatherType isEqualToString:@"Clouds"]){
        weatherImageName = @"scattered clouds";
    } else if ([weatherType isEqualToString:@"Clouds"]){
        weatherImageName = @"broken clouds";
    } else if ([weatherType isEqualToString:@"Drizzle"]){
        weatherImageName = @"shower rain";
    } else if ([weatherType isEqualToString:@"Rain"]){
        weatherImageName = @"rain";
    } else if ([weatherType isEqualToString:@"Thunderstorm"]){
        weatherImageName = @"thunderstorm";
    } else if ([weatherType isEqualToString:@"Snow"]){
        weatherImageName = @"snow";
    } else if ([weatherType isEqualToString:@"Mist"]){
        weatherImageName = @"mist";
    }else if([weatherType isEqualToString:@"Fog"]){
        weatherImageName = @"mist";
    } else{
        weatherImageName = @"";
    }
    return [NSImage imageNamed:weatherImageName];
}

- (NSArray *)getAllKeys{
    return [_sdManager.getKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (NSString *)encodeBlowfish:(NSString *)str withKey:(NSString *)key iv:(NSString *)iv{
    return [self blowfishWithOpperation:kCCEncrypt str:str key:key iv:iv];
}

- (NSString *)decodeBlowfish:(NSString *)str withKey:(NSString *)key iv:(NSString *)iv {
    return [self blowfishWithOpperation:kCCDecrypt str:str key:key iv:iv];
}

////////////////////////////////////////////////////
// 文字列をblowfish暗号化する
- (NSString *)blowfishWithOpperation:(CCOperation)operation str:(NSString *)str key:(NSString *)key iv:(NSString *)iv {
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = nil;
    
    if(operation == kCCEncrypt){
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *myEnc = [NSMutableData dataWithLength:kCCKeySizeMaxBlowfish+str.length];
        
        size_t wSize = ( ( myEnc.length + kCCBlockSizeBlowfish - 1 ) / kCCBlockSizeBlowfish ) * kCCBlockSizeBlowfish;
        char   v[ wSize ];
        
        CCCrypt(operation,//kCCEncrypt,
                kCCAlgorithmBlowfish,
                kCCOptionPKCS7Padding,
                keyData.bytes,
                keyData.length,
                ivData.bytes,
                data.bytes,
                data.length,
                v,
                wSize,
                &wSize);
        NSData * result = [NSData dataWithBytes:v length:wSize];
        
        return [result base64EncodedStringWithOptions:0];
        
    }else{
        data = [[NSData alloc] initWithBase64EncodedString:str options:0];
        
        NSMutableData *myEnc = [NSMutableData dataWithLength:kCCKeySizeMaxBlowfish+str.length];
        
        size_t	wSize = ( ( myEnc.length + kCCBlockSizeBlowfish - 1 ) / kCCBlockSizeBlowfish ) * kCCBlockSizeBlowfish;
        char	v[ wSize ];
        
        CCCrypt(kCCDecrypt,
                kCCAlgorithmBlowfish,
                kCCOptionPKCS7Padding,
                keyData.bytes,
                keyData.length,
                ivData.bytes,
                data.bytes,
                data.length,
                v,
                wSize,
                &wSize);
        NSString * g = [[NSString alloc] initWithData:[NSData dataWithBytes:v length:wSize] encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",g);
        
        return g;
    }
}


@end
