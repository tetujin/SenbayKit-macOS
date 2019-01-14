//
//  SenbayReader.h
//  Pods-SenbayKit-macOS_Example
//
//  Created by Yuuki Nishiyama on 2019/01/13.
//

#import <Foundation/Foundation.h>
#import <ZXingObjC/ZXingObjC.h>
#import <QuartzCore/QuartzCore.h>
#import "SenbayData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SenbayReaderDelegate <NSObject>
@optional
- (void) didDetectQRcode:(NSString *) qrcode;
- (void) didDecodeQRcode:(NSDictionary<NSString *, NSObject *> *) data;
- (void) didChangeCaptureArea:(CGRect)rect;
@end


@interface SenbayReaderConfig : NSObject
- (instancetype) initWithBuilderBlock:(void(^)(SenbayReaderConfig *config))builderBlock;
@property double captureAreaX;
@property double captureAreaY;
@property double captureAreaWidth;
@property double captureAreaHeight;
@property int frequency;
@property CGDirectDisplayID displayId;
@property bool skipDuplicateData;
@property int baseNumber;
@property bool debug;
@property (nullable) NSString * encryptionKey;
@end


@interface SenbayReader : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak, nonatomic) id <SenbayReaderDelegate> delegate;
@property (readonly) SenbayReaderConfig * config;
- (instancetype)initWithConfig:(SenbayReaderConfig *)config;
- (void) start;
- (void) stop;
- (void) adjustCaptureArea;
- (void) setCaptureAreaWithRect:(CGRect)rect;
- (void) setCaptureAreaWithX:(double)x y:(double)y width:(double)width height:(double)height;

@end



NS_ASSUME_NONNULL_END
