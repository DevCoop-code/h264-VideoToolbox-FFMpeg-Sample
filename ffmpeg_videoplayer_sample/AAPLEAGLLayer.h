//
//  AAPLEAGLLayer.h
//  ffmpeg_videoplayer_sample
//
//  Created by HanGyo Jeong on 03/11/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#include <CoreVideo/CoreVideo.h>

@interface AAPLEAGLLayer : CAEAGLLayer

@property CVPixelBufferRef pixelBuffer;

- (id)initWithFrame:(CGRect)frame;
- (void)resetRenderBuffer;

@end
