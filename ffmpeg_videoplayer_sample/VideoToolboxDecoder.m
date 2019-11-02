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
        
    }
    return self;
}

#pragma mark - VideoToolbox Activity
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
