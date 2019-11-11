//
//  VideoAppCameraSource.m
//  VideoApp
//
//  Created by Ryan Payne on 12/14/18.
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

#import "VideoAppCameraSource.h"
#import "LocalMediaController+Internal.h"
#import "TVILocalVideoTrack+Mirroring.h"

static const int32_t kVideoAppCameraSourceMinWidth = 640;
static const int32_t kVideoAppCameraSourceMinHeight = 480;
static const CGFloat kVideoAppCameraSourceAdjustmentFactor = 1.2;

@interface VideoAppCameraSource () <TVICameraSourceDelegate>

@property (nonatomic, strong) TVICameraSource *cameraSource;
@property (nonatomic, strong) TVILocalVideoTrack *localVideoTrack;
@property (nonatomic, weak) LocalMediaController *localMediaController;

@end

@implementation VideoAppCameraSource

- (instancetype)initWithLocalMediaController:(LocalMediaController *)localMediaController {
    self = [super init];

    if (self != nil) {
        _localMediaController = localMediaController;
    }

    return self;
}

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Prevent leaking the CameraSource in case a Track/Source has been created.
    [_cameraSource stopCapture];
}

- (TVILocalVideoTrack *)localVideoTrack {
    if (_localVideoTrack == nil) {
        [self createCameraSource];
    }

    return _localVideoTrack;
}

- (void)createCameraSource {
    TVICameraSourceOptions *options = [TVICameraSourceOptions optionsWithBlock:^(TVICameraSourceOptionsBuilder * _Nonnull builder) {
        if (@available(iOS 13, *)) {
            UIWindowScene *keyScene = [UIApplication sharedApplication].keyWindow.windowScene;
            builder.orientationTracker = [TVIUserInterfaceTracker trackerWithScene:keyScene];
        }
    }];
    self.cameraSource = [[TVICameraSource alloc] initWithOptions:options delegate:self];

    if (self.cameraSource == nil) {
        NSLog(@"Unable to create a capturer...");
        return;
    }

    self.localVideoTrack = [TVILocalVideoTrack trackWithSource:self.cameraSource
                                                       enabled:YES
                                                          name:@"camera"];

    [self startCameraSourceWithPosition:AVCaptureDevicePositionFront];
}

- (void)startCameraSourceWithPosition:(AVCaptureDevicePosition)position {
    // Find a format and start capture.
    TVIVideoFormat *preferredFormat = nil;
    AVCaptureDevice *frontCamera = [TVICameraSource captureDeviceForPosition:position];
    NSOrderedSet<TVIVideoFormat *> *supportedFormats = [TVICameraSource supportedFormatsForDevice:frontCamera];
    for (TVIVideoFormat *format in supportedFormats) {
        if (format.dimensions.width >= kVideoAppCameraSourceMinWidth &&
            format.dimensions.height >= kVideoAppCameraSourceMinHeight) {
            preferredFormat = format;
            break;
        }
    }

    NSLog(@"Supported formats were:\n%@", supportedFormats);

    CMVideoDimensions cropDimensions = preferredFormat.dimensions;
    if (cropDimensions.width > cropDimensions.height) {
        cropDimensions.width = cropDimensions.height * kVideoAppCameraSourceAdjustmentFactor;
    } else {
        cropDimensions.height = cropDimensions.width * kVideoAppCameraSourceAdjustmentFactor;
    }

    TVIVideoFormat *outputFormat = [[TVIVideoFormat alloc] init];
    outputFormat.dimensions = cropDimensions;
    outputFormat.pixelFormat = preferredFormat.pixelFormat;
    outputFormat.frameRate = 0;

    NSLog(@"Cropping camera output to format: %@", outputFormat);

    [self.cameraSource requestOutputFormat:outputFormat];

    typeof(self) __weak weakSelf = self;
    [self.cameraSource startCaptureWithDevice:frontCamera format:preferredFormat completion:^(AVCaptureDevice *device,
                                                                                              TVIVideoFormat *startFormat,
                                                                                              NSError *error) {
        if (!error) {
            [weakSelf.localMediaController videoCaptureStarted];
        }
    }];
}

- (void)destroyLocalVideoTrack {
    [self.cameraSource stopCaptureWithCompletion:^(NSError *error) {
        self.localVideoTrack = nil;
        self.cameraSource = nil;
    }];
}

- (void)flipCamera {
    AVCaptureDevicePosition position = self.cameraSource.device.position;
    AVCaptureDevicePosition nextPosition = position == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;

    typeof(self) __weak weakSelf = self;
    [self.cameraSource selectCaptureDevice:[TVICameraSource captureDeviceForPosition:nextPosition] completion:^(AVCaptureDevice *device, TVIVideoFormat *format, NSError *error) {
        if (!error) {
            [weakSelf.localMediaController videoCaptureStarted];
        }
    }];
}

- (BOOL)shouldMirrorLocalVideoView {
    return [self.localVideoTrack tvi_shouldMirror];
}

#pragma mark - TVICameraSourceDelegate

- (void)cameraSourceInterruptionEnded:(TVICameraSource *)source {

}

- (void)cameraSourceWasInterrupted:(TVICameraSource *)source reason:(AVCaptureSessionInterruptionReason)reason {

}

- (void)cameraSource:(TVICameraSource *)source didFailWithError:(NSError *)error {

}

@end
