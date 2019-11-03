//
//  VideoToolboxDecoder.m
//  ffmpeg_videoplayer_sample
//
//  Created by HanGyo Jeong on 02/11/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import "VideoToolboxDecoder.h"

@implementation VideoToolboxDecoder{
    AVCodecParameters *codecpar;
    CMVideoFormatDescriptionRef formatDescription;
    VTDecompressionSessionRef decompressSession;
}

- (instancetype)initWithExtradata{
    self = [super init];
    if(self){
        codecpar = get_codec_parameters();
        [self createVideoToolboxDecoder];
    }
    return self;
}

- (int)decodeVideo:(CVPixelBufferRef *)pixelBuffer{
    int err = 0;
    NAL_UNIT nal_unit = {NULL, 0};
    err = get_video_packet(&nal_unit);
    if(err < 0){
        return err;
    }
    
}

#pragma mark - VideoToolbox Activity
static void didDecompress(void *decompressionOutputRefCon,
                          void *sourceFrameRefCon,
                          OSStatus status,
                          VTDecodeInfoFlags infoFlags,
                          CVImageBufferRef pixelBuffer,
                          CMTime presentationTimeStamp,
                          CMTime presentationDuration){
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

- (int)createVideoToolboxDecoder{
    /*
     [width & height]
     Width & Height of video frame(pixel)
     */
    int width = codecpar->width;
    int height = codecpar->height;
    /*
     [extradata]
     Extra binary data needed for initializing the decoder, codec-dependent
     */
    int extradata_size = codecpar->extradata_size;
    uint8_t *extradata = codecpar->extradata;
    
    OSStatus status;
    
    //PixelAspectRatio
    CFMutableDictionaryRef par = CFDictionaryCreateMutable(NULL,
                                                           0,
                                                           &kCFTypeDictionaryKeyCallBacks,
                                                           &kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef atoms = CFDictionaryCreateMutable(NULL,
                                                           0,
                                                           &kCFTypeDictionaryKeyCallBacks,
                                                           &kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef extensions = CFDictionaryCreateMutable(NULL,
                                                           0,
                                                           &kCFTypeDictionaryKeyCallBacks,
                                                           &kCFTypeDictionaryValueCallBacks);
    NSLog(@"Frame width: %d, height: %d", width, height);
    
    /* CVPixelAspectRatio dict */
    /*
     CoreFoundation - CFSTR
     Creates an immutable string from a constant compile-time string
     */
    dict_set_i32(par, CFSTR("HorizontalSpacing"), 0);
    dict_set_i32(par, CFSTR("VerticalSpacing"), 0);
    
    /*SampleDescriptionExtensionAtoms dict*/
    dict_set_data(atoms, CFSTR("avcC"), (uint8_t*)extradata, extradata_size);
    
    /*Extensions dict*/
    dict_set_string(extensions, CFSTR("CVImageBufferChromaLocationBottomField"), "left");
    dict_set_string(extensions, CFSTR("CVImageBufferChromaLocationTopField"), "left");
    dict_set_boolean(extensions, CFSTR("FullRangeVideo"), FALSE);
    dict_set_object(extensions, CFSTR("CVPixelAspectRatio"), (CFTypeRef *)par);
    dict_set_object(extensions, CFSTR("SampleDescriptionExtensionAtoms"), (CFTypeRef *)atoms);
    
    status = CMVideoFormatDescriptionCreate(NULL,
                                            kCMVideoCodecType_H264,
                                            width,
                                            height,
                                            extensions,
                                            &(formatDescription));
    
    CFRelease(extensions);
    CFRelease(atoms);
    CFRelease(par);
    
    if(status != 0){
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: creating format description failed. Description: %@", [error description]);
        return -1;
    }
    
    CFMutableDictionaryRef destinationPixelBufferAttributes;
    destinationPixelBufferAttributes = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferPixelFormatTypeKey, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferWidthKey, width);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferHeightKey, height);
    dict_set_boolean(destinationPixelBufferAttributes, kCVPixelBufferOpenGLESCompatibilityKey, YES);
    
    /*VTDecompressionOutputCallbackRecord is a simple structure with a pointer to the callback function invoked when frame decompression */
    VTDecompressionOutputCallbackRecord outputCallback;
    outputCallback.decompressionOutputCallback = didDecompress;
    outputCallback.decompressionOutputRefCon = NULL;
    status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                          formatDescription,
                                          NULL,
                                          destinationPixelBufferAttributes,
                                          &outputCallback,
                                          &(decompressSession));
    if(status != noErr){
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: Creating decompression session failed. Description: %@", [error description]);
        return -1;
    }
    return 0;
}

#pragma mark - Utils
static void dict_set_i32(CFMutableDictionaryRef dict, CFStringRef key, int32_t value){
    CFNumberRef number;     //CFNumber - CFNumber encapsulates C scalar (numeric) types
    number = CFNumberCreate(NULL, kCFNumberSInt32Type, &value);
    CFDictionarySetValue(dict, key, number);    //Sets the value corresponding to a given key.
    CFRelease(number);
}

static void dict_set_data(CFMutableDictionaryRef dict, CFStringRef key, uint8_t *value, uint64_t length){
    CFDataRef data;
    data = CFDataCreate(NULL, value, (CFIndex)length);
    CFDictionarySetValue(dict, key, data);
    CFRelease(data);
}

static void dict_set_string(CFMutableDictionaryRef dict, CFStringRef key, const char *value){
    CFStringRef string;
    string = CFStringCreateWithCString(NULL, value, kCFStringEncodingASCII);
    CFRelease(string);
}

static void dict_set_boolean(CFMutableDictionaryRef dict, CFStringRef key, BOOL value){
    CFDictionarySetValue(dict, key, value ? kCFBooleanTrue : kCFBooleanFalse);
}

static void dict_set_object(CFMutableDictionaryRef dict, CFStringRef key, CFTypeRef *value){    //CFTypeRef - An untyped "generic" reference to any Core Foundation object.
    CFDictionarySetValue(dict, key, value);
}
@end
