// OPMediaPermissionOperation.m
// Copyright (c) 2015 Tom Wilson <tom@toms-stuff.net>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@import AVFoundation;

#import "OPMediaPermissionOperation.h"
#import "OPOperationConditionMutuallyExclusive.h"

@interface OPMediaPermissionOperation()

@property (copy, nonatomic) NSString *mediaType;

@end

@implementation OPMediaPermissionOperation

#pragma mark - Lifecycle
#pragma mark -

- (instancetype)initWithMediaType:(NSString *)mediaType
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _mediaType = [mediaType copy];
    
    // Temporarily: let's relax the alert presentation exclusivity as we're seeing a condition where
    // multiple media operations are enqueued.
    // [self addCondition:[OPOperationConditionMutuallyExclusive alertPresentationExclusivity]];
    
    return self;
}

#pragma mark - Overrides
#pragma mark -

- (void)execute
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:[self mediaType]];
    if (status == AVAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [AVCaptureDevice requestAccessForMediaType:[self mediaType] completionHandler:^(BOOL granted) {
                [self finish];
            }];
        });
    } else {
        [self finish];
    }
}

@end
