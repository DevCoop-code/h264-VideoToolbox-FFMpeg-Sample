//
//  DecodingViewController.m
//  ffmpeg_videoplayer_sample
//
//  Created by HanGyo Jeong on 03/11/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import "DecodingViewController.h"

@interface DecodingViewController (){
    int playState;
}

@property (nonatomic, strong) NSURL *inputUrl;
@property (nonatomic, strong) VideoToolboxDecoder *videoToolboxDecoder;
@property (nonatomic, strong) AAPLEAGLLayer *glLayer;

@end

@implementation DecodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int err = 0;
    self.view.backgroundColor = [UIColor lightGrayColor];
    _glLayer = [[AAPLEAGLLayer alloc]initWithFrame:self.view.bounds];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"" ofType:@""];
    [self initFFMpegConfigWithPath:path];
    
    err = [self initVideoToolboxDecoder];
    if(err < 0)
        return;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    playState = 0;
    [self.view.layer addSublayer:_glLayer];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self runVideoToolboxDecoder];
    });
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeDecoder];
}

# pragma mark - VideoToolbox
- (int)initVideoToolboxDecoder{
    _videoToolboxDecoder = [[VideoToolboxDecoder alloc]initWithExtradata];
    if(!_videoToolboxDecoder){
        NSLog(@"Error: VideoToolbox decoder initialization failed");
        return -1;
    }
    return 0;
}

- (int)runVideoToolboxDecoder{
    int err = 0;
    while (1) {
        if(playState == 1){
            break;
        }
        
        CVPixelBufferRef pixelBuffer = NULL;
        err = [_videoToolboxDecoder decodeVideo:&pixelBuffer];
        if(err < 0){
            break;
        }
        
        if(pixelBuffer){
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.glLayer.pixelBuffer = pixelBuffer;
            });
            CVPixelBufferRelease(pixelBuffer);
        }
        
        [NSThread sleepForTimeInterval:0.025];
    }
    
    return 0;
}

# pragma mark - FFMpeg demuxer
- (int)initFFMpegConfigWithPath: (NSString*)url{
    int err = 0;
    err = init_ffmpeg_config([url UTF8String], 0);
    return err;
}

- (void)closeDecoder{
    playState = 1;
    ffmpeg_demuxer_release();
    [_videoToolboxDecoder releaseVideoToolboxDecoder];
}
@end
