//
//  Copyright (C) 2019 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "VideoAppCameraSource.h"
#import "LocalMediaController+Internal.h"
#import "TVILocalVideoTrack+Mirroring.h"
#import "VideoApp-Swift.h"

// 640x480 squarish crop (1.13:1)
static const CMVideoDimensions kVideoAppCameraSourceDimensions = (CMVideoDimensions){544, 480};
// 1024x768 squarish crop (1.25:1) on most iPhones. 1280x720 squarish crop (1.25:1) on the iPhone X and models that don't have 1024x768.
static const CMVideoDimensions kVideoAppCameraSourceSimulcastDimensions = (CMVideoDimensions){900, 720};

static const int32_t kVideoAppCameraSourceFrameRate = 20;
// With simulcast enabled there are 3 temporal layers, allowing a frame rate of f/4.
static const int32_t kVideoAppCameraSourceSimulcastFrameRate = 24;

TVIVideoFormat *VideoAppCameraSourceSelectVideoFormatBySize(AVCaptureDevice *device, CMVideoDimensions targetSize) {
    TVIVideoFormat *selectedFormat = nil;
    // Ordered from smallest to largest.
    NSOrderedSet<TVIVideoFormat *> *formats = [TVICameraSource supportedFormatsForDevice:device];

    for (TVIVideoFormat *format in formats) {
        if (format.pixelFormat != TVIPixelFormatYUV420BiPlanarFullRange) {
            continue;
        }
        CMVideoDimensions dimensions = format.dimensions;

        // Cropping might be used if there is not an exact match.
        if (dimensions.width >= targetSize.width && dimensions.height >= targetSize.height) {
            selectedFormat = format;
            break;
        }
    }
    return selectedFormat;
}

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
        // If a Group Room is being requested, take a best guess and remove rotation tags using hardware acceleration.
        if ([SwiftToObjc isGroupTopology]) {
            builder.rotationTags = TVICameraSourceOptionsRotationTagsRemove;
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
    AVCaptureDevice *camera = [TVICameraSource captureDeviceForPosition:position];
    CMVideoDimensions dimensions;
    CGFloat cropRatio;
    int32_t frameRate;
    if ([SwiftToObjc enableVP8Simulcast]) {
        cropRatio = (CGFloat)kVideoAppCameraSourceSimulcastDimensions.width / (CGFloat)kVideoAppCameraSourceSimulcastDimensions.height;
        dimensions = kVideoAppCameraSourceSimulcastDimensions;
        frameRate = kVideoAppCameraSourceSimulcastFrameRate;
    } else {
        cropRatio = (CGFloat)kVideoAppCameraSourceDimensions.width / (CGFloat)kVideoAppCameraSourceDimensions.height;
        dimensions = kVideoAppCameraSourceDimensions;
        frameRate = kVideoAppCameraSourceFrameRate;
    }
    TVIVideoFormat *preferredFormat = VideoAppCameraSourceSelectVideoFormatBySize(camera, dimensions);
    preferredFormat.frameRate = MIN(preferredFormat.frameRate, frameRate);

    CMVideoDimensions cropDimensions = preferredFormat.dimensions;
    if (cropDimensions.width > cropDimensions.height) {
        cropDimensions.width = cropDimensions.height * cropRatio;
    } else {
        cropDimensions.height = cropDimensions.width * cropRatio;
    }
    
    TVIVideoFormat *outputFormat = [[TVIVideoFormat alloc] init];
    outputFormat.dimensions = cropDimensions;
    outputFormat.pixelFormat = preferredFormat.pixelFormat;
    outputFormat.frameRate = 0;

    NSLog(@"Cropping camera output to format: %@", outputFormat);

    [self.cameraSource requestOutputFormat:outputFormat];

    typeof(self) __weak weakSelf = self;
    [self.cameraSource startCaptureWithDevice:camera format:preferredFormat completion:^(AVCaptureDevice *device,
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
    [self.localMediaController cameraSourceInterruptionEnded];
}

- (void)cameraSourceWasInterrupted:(TVICameraSource *)source reason:(AVCaptureSessionInterruptionReason)reason {
    [self.localMediaController cameraSourceWasInterrupted];
}

- (void)cameraSource:(TVICameraSource *)source didFailWithError:(NSError *)error {

}

@end
