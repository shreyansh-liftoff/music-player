// MediaPlayerInfoModule.m
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(MediaPlayerModule, NSObject)

// Define the `setMediaPlayerInfo` method with the correct parameter types
RCT_EXTERN_METHOD(setMediaPlayerInfo:(NSURL *)url
                              title:(NSString *)title
                              artist:(NSString *)artist
                              album:(NSString *)album
                              duration:(double)duration)

// Define the methods for audio controls
RCT_EXTERN_METHOD(playAudio)

RCT_EXTERN_METHOD(pauseAudio)

RCT_EXTERN_METHOD(stopAudio)

@end
