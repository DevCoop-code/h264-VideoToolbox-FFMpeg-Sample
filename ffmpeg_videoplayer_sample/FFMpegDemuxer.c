//
//  FFMpegDemuxer.c
//  ffmpeg_videoplayer_sample
//
//  Created by HanGyo Jeong on 27/10/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#include "FFMpegDemuxer.h"

typedef struct FFDemuxer {
    int video_stream_index;
    AVCodec *codec;
    AVCodecContext *codec_ctx;
    AVFormatContext *fmt_ctx;
    AVPacket pkt;
} FFDemuxer;
FFDemuxer demuxer = {-1, NULL};

int init_ffmpeg_config_mp4(const char *input_file_name);

#pragma mark - API Implementation
int init_ffmpeg_config(const char *input_file_name, int format){
    int err = 0;
    /*
     Initialize libavformat and register all the muxers, demuxers and
     protocols. If you do not call this function, then you can select
     exactly which formats you want to support.
     */
    av_register_all();
    err = init_ffmpeg_config_mp4(input_file_name);
    if(err < 0){
        return err;
    }
    
    return err;
}

AVCodecParameters* get_codec_parameters(void){
    AVCodecParameters *codecpar = avcodec_parameters_alloc();
    /**
    * Fill the parameters struct based on the values from the supplied codec
    * context. Any allocated fields in par are freed and replaced with duplicates
    * of the corresponding fields in codec.
    *
    * @return >= 0 on success, a negative AVERROR code on failure
    */
    if(avcodec_parameters_from_context(codecpar, demuxer.codec_ctx) < 0){
        return NULL;
    }
    return codecpar;
}

int get_video_packet(NAL_UNIT *nalu){
    int got_video_frame = 0;
    while(av_read_frame(demuxer.fmt_ctx, &(demuxer.pkt)) >= 0){
        if(demuxer.pkt.stream_index != demuxer.video_stream_index){
            continue;
        }
        
        got_video_frame = 1;
        nalu->nal_size = demuxer.pkt.size;
        nalu->nal_buf = demuxer.pkt.data;
        break;
    }
    
    if(!got_video_frame){
        return -1;
    }
    return 0;
}

void ffmpeg_demuxer_release(void){
    if(demuxer.fmt_ctx){
        avformat_close_input(&demuxer.fmt_ctx);
        demuxer.fmt_ctx = NULL;
    }
    
    if(demuxer.codec_ctx){
        avcodec_free_context(&demuxer.codec_ctx);
    }
    
    printf("FFMpeg demuxer released.\n");
}

#pragma mark - MP4 format
int init_ffmpeg_config_mp4(const char *input_file_name){
    AVStream *video_stream = NULL;
    if(avformat_open_input(&demuxer.fmt_ctx, input_file_name, NULL, NULL) < 0){
        printf("Error: Open input file failed\n");
        return -1;
    }
    
    if(avformat_find_stream_info(demuxer.fmt_ctx, NULL)){
        printf("Error: Find stream info error.\n");
        return -1;
    }
    
    int ret = av_find_best_stream(demuxer.fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if(ret < 0){
        printf("Error: Cannot find video stream.\n");
        return -1;
    }
    demuxer.video_stream_index = ret;
    video_stream = demuxer.fmt_ctx->streams[demuxer.video_stream_index];
    
    demuxer.codec = avcodec_find_decoder(video_stream->codecpar->codec_id);
    if(!demuxer.codec){
        printf("Error: find decoder h.264 failed in libavcodec. Rebuild ffmpeg with h.264 encoder enabled.\n");
        return -1;
    }
    
    demuxer.codec_ctx = avcodec_alloc_context3(demuxer.codec);
    if(!demuxer.codec_ctx){
        printf("Error: AVCodecContext instance allocation failed.\n");
        return -1;
    }
    
    if(avcodec_parameters_to_context(demuxer.codec_ctx, video_stream->codecpar) < 0){
        printf("Error: AVCodecContext instance allocation failed.\n");
        return -1;
    }
    
    if(avcodec_open2(demuxer.codec_ctx, demuxer.codec, NULL) < 0){
        printf("Error: Open codec failed. \n");
        return -1;
    }
    
    /*
     Initialize packet, set data to null, let the demuxer fill it
     */
    av_init_packet(&(demuxer.pkt));
    demuxer.pkt.data = NULL;
    demuxer.pkt.size = 0;
    
    printf("Configuration for h.264 mp4 succeeded.\n");
    return 0;
}
