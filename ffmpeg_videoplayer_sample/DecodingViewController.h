//
//  DecodingViewController.h
//  ffmpeg_videoplayer_sample
//
//  Created by HanGyo Jeong on 03/11/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AAPLEAGLLayer.h"
#import "VideoToolboxDecoder.h"
#include "FFMpegDemuxer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DecodingViewController : UIViewController

- (instancetype)initWithURL: (NSURL *)url;

- (void)closeDecoder;

@end

NS_ASSUME_NONNULL_END
