//
//  SenbayReader.m
//  Pods-SenbayKit-macOS_Example
//
//  Created by Yuuki Nishiyama on 2019/01/13.
//

#import "SenbayReader.h"
#import "SenbayFormat.h"
#import "SenbayData.h"

@implementation SenbayReaderConfig

- (instancetype)init{
    self = [super init];
    if (self != nil){
        _captureAreaX      = 0;
        _captureAreaY      = 0;
        _captureAreaWidth  = 256;
        _captureAreaHeight = 256;
        _frequency     = 60;
        _displayId     = kCGDirectMainDisplay;
        _baseNumber    = 122;
        _skipDuplicateData = YES;
        _debug         = NO;
        _encryptionKey = nil;
    }
    return self;
}

- (instancetype) initWithBuilderBlock:(void(^)(SenbayReaderConfig *config))builderBlock{
    self = [self init];
    if (self != nil){
        builderBlock(self);
    }
    return self;
}

@end



@implementation SenbayReader{
    AVCaptureScreenInput *input;
    AVCaptureSession * session;    
    ZXQRCodeReader * qrcodeReader;
    SenbayFormat * senbayFormat;
    NSString * lastData;
}

- (instancetype)init{
    SenbayReaderConfig * config = [[SenbayReaderConfig alloc] init];
    return [self initWithConfig:config];
}

- (instancetype)initWithConfig:(SenbayReaderConfig *)config{
    self = [super init];
    if (self != nil){
        qrcodeReader = [[ZXQRCodeReader alloc] init];
        senbayFormat = [[SenbayFormat alloc] init];
        lastData     = @"";
        if (config) {
            _config = config;
        }else{
            _config = [[SenbayReaderConfig alloc] init];
        }
    }
    return self;
}

- (void)start{
    CMTime frame = CMTimeMake(1,_config.frequency);
    NSLog(@"Capture Area: %f, %f, %f, %f", _config.captureAreaY, _config.captureAreaX, _config.captureAreaWidth, _config.captureAreaHeight);
    
    // Create a ScreenInput with the display and add it to the session
    input = [[AVCaptureScreenInput alloc] initWithDisplayID:_config.displayId];
    [input setCropRect:CGRectMake(_config.captureAreaX, _config.captureAreaY, _config.captureAreaWidth, _config.captureAreaHeight)];
    input.minFrameDuration = frame;
    
    NSMutableDictionary*        settings;
    AVCaptureVideoDataOutput*   dataOutput;
    settings = [NSMutableDictionary dictionary];
    [settings setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.videoSettings = settings;
    
    dispatch_queue_t videoDataQueue = dispatch_queue_create("jp.ac.sfc.keio.ht.tetujin.senbay.videoDataQueue", DISPATCH_QUEUE_SERIAL);
    [dataOutput setSampleBufferDelegate:self queue:videoDataQueue];
    
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset320x240;
    [session addInput:input];
    [session addOutput:dataOutput];
    [session startRunning];
}

-(void)stop{
    [session stopRunning];
}

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection
{
    CVPixelBufferRef pixelBuffer = NULL;
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer && (CFGetTypeID(imageBuffer) == CVPixelBufferGetTypeID())) {
        pixelBuffer = (CVPixelBufferRef)imageBuffer;
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        if(imageBuffer){
            ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithBuffer:pixelBuffer];
            ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
            
            NSError *error = nil;
            
            ZXDecodeHints *hints = [ZXDecodeHints hints];
            [hints setTryHarder:YES];
            [hints setEncoding:NSUTF8StringEncoding];
            
            ZXResult *zxResult = [qrcodeReader decode:bitmap
                                                hints:hints
                                                error:&error];
            
            if (zxResult) {
                NSString * result = [zxResult.text mutableCopy];
                if(![lastData isEqualToString:result] && !_config.skipDuplicateData) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.delegate respondsToSelector:@selector(didDetectQRcode:)]) {
                            [self.delegate didDetectQRcode:result];
                        }
                        
                        SenbayData * data = nil;
                        if(self->_config.encryptionKey){
                            data = [[SenbayData alloc] initWithString:result
                                                        encryptionKey:self->_config.encryptionKey
                                                                baseX:self->_config.baseNumber];
                        }else{
                            data = [[SenbayData alloc] initWithString:[result mutableCopy]
                                                                baseX:self->_config.baseNumber];
                        }
                        
                        if (data.sdManager.source){
                            if ([self.delegate respondsToSelector:@selector(didDecodeQRcode:)]) {
                                [self.delegate didDecodeQRcode:[data.sdManager.source mutableCopy]];
                            }
                        }
                        self->lastData = result;
                    });
                }
                lastData = zxResult.text;
            }
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
}

- (void) adjustCaptureArea {
    @autoreleasepool {
        // 画面キャプチャのオリジナルサイズを取得 -> 画面の比率とは異なる
        CGImageRef image = CGDisplayCreateImage(_config.displayId);
        
        CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:image];
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        float originalHeight = CGImageGetHeight(image);
        
        if(pixelBuffer){
            
            ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithBuffer:pixelBuffer];
            ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
            
            NSError *error = nil;
            ZXDecodeHints *hints = [ZXDecodeHints hints];
            [hints setTryHarder:YES];
            [hints setEncoding:NSUTF8StringEncoding];
            
            ZXResult *zxResult = [qrcodeReader decode:bitmap
                                                hints:hints
                                                error:&error];
            
            if( zxResult != nil){
                NSMutableArray *points    = zxResult.resultPoints;
                ZXResultPoint *topRight   = points[2];
                ZXResultPoint *topLeft    = points[1];
                ZXResultPoint *bottomLeft = points[0];
                //ZXResultPoint *buttomRight = points[3];
                
                _config.captureAreaWidth  = (topRight.x)-(topLeft.x) + 40;
                _config.captureAreaHeight = (bottomLeft.y)-(topLeft.y) + 40 ;
                _config.captureAreaX      = topLeft.x - 20;
                _config.captureAreaY      = originalHeight - topLeft.y - _config.captureAreaHeight + 20;
                
                //Retina Displayの場合は、画面サイズ（画面キャプチャの画像）が2倍になるので、元の画面と合わせるためには、各要素の位置・サイズを半分にする
                NSScreen *sc = [NSScreen mainScreen];
                if ([sc backingScaleFactor] == 2.0f) {
                    // NSLog(@"retina");
                    _config.captureAreaWidth  = _config.captureAreaWidth/2.0f + 20;
                    _config.captureAreaHeight = _config.captureAreaHeight/2.0f + 20;
                    _config.captureAreaX      = _config.captureAreaX/2.0f - 10;
                    _config.captureAreaY      = _config.captureAreaY/2.0f - 10;
                }
                
                [self setCaptureAreaWithX:_config.captureAreaX
                                        y:_config.captureAreaY
                                    width:_config.captureAreaWidth
                                   height:_config.captureAreaHeight];
            }
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVPixelBufferRelease(pixelBuffer);
        CGImageRelease(image);
    }
}

- (void) setCaptureAreaWithRect:(CGRect)rect{
    [self setCaptureAreaWithX:rect.origin.x
                               y:rect.origin.y
                           width:rect.size.width
                          height:rect.size.height];
}

- (void) setCaptureAreaWithX:(double)x y:(double)y width:(double)width height:(double)height {
    
    _config.captureAreaX      = x;
    _config.captureAreaY      = y;
    _config.captureAreaWidth  = width;
    _config.captureAreaHeight = height;
    
    [session beginConfiguration];
    
    /* Is this display the current capture input? */
    /* Display is not the current input, so remove it. */
    [session removeInput:input];
    AVCaptureScreenInput *newScreenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:kCGDirectMainDisplay];
    
    input = newScreenInput;
    if ( [session canAddInput:input] ) {
        /* Add the new display capture input. */
        [session addInput:input];
    }
    
    CGRect cr = CGRectMake(_config.captureAreaX,
                           _config.captureAreaY,
                           _config.captureAreaWidth,
                           _config.captureAreaHeight);
    [input setCropRect:cr];
    // [window setFrame:NSMakeRect(captureAreaX, captureAreaY, captureAreaWidth, captureAreaHeight) display:YES];
    CMTime frame = CMTimeMake(1,_config.frequency);
    input.minFrameDuration = frame;
    
    /* Commits the configuration changes. */
    [session commitConfiguration];
    
    if ([self.delegate respondsToSelector:@selector(didChangeCaptureArea:)]) {
        [self.delegate didChangeCaptureArea:cr];
    }
}


- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    if(image == nil){
        return nil;
    }
    
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameSize.width,
                                          frameSize.height,
                                          kCVPixelFormatType_32ARGB,
                                          CFBridgingRetain(options),
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


@end
