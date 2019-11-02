//
//  VideoToolboxDecoder.h
//  ffmpeg_videoplayer_sample
//
//  Created by HanGyo Jeong on 02/11/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

/*
 CoreFoundation
 Access low-level functions, primitive data types, and various collection types that are bridged seamlessly with the Foundation framework
 */
#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFDictionary.h>
#import <VideoToolbox/VideoToolbox.h>

#include "FFMpegDemuxer.h"
#include "libavcodec/avcodec.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoToolboxDecoder : NSObject

- (instancetype)initWithExtradata;

- (int)decodeVideo: (CVPixelBufferRef *)pixelBuffer;

- (void)releaseVideoToolboxDecoder;
@end

NS_ASSUME_NONNULL_END
