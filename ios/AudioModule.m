//
//  AudioModule.m
//  MusicPlayer
//
//  Created by Liftoff on 20/01/25.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(AudioModule, NSObject)
// Expose the methods to React Native using RCT_EXTERN_METHOD

RCT_EXTERN_METHOD(setMediaPlayerInfo:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(nonnull NSString *)duration)

RCT_EXTERN_METHOD(downloadAndPlayAudio:(NSURL *)remoteURL
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(pauseAudio);

RCT_EXTERN_METHOD(stopAudio);

RCT_EXTERN_METHOD(seek:(double)timeInSeconds);

RCT_EXTERN_METHOD(getTotalDuration:(NSURL *)remoteURL
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject);

// Required for RCT_EXTERN_MODULE
+ (BOOL)requiresMainQueueSetup
{
    return YES; // If your module does not need to run on the main thread
}

@end
