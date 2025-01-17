#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(AudioModule, NSObject)

RCT_EXTERN_METHOD(getTotalDuration:(NSString *)filePath callback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(play:(NSString *)filePath resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(pause)

RCT_EXTERN_METHOD(stop)

RCT_EXTERN_METHOD(seek:(double)interval resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startTracking)

RCT_EXTERN_METHOD(stopTracking)

RCT_EXTERN_METHOD(setMediaPlayerInfo:(NSString *)title artist:(NSString *)artist imageURL:(nullable NSString *)imageURL)

@end
