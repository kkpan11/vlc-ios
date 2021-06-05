/*****************************************************************************
 * VLCPlayerDisplayController.h
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2015 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Tobias Conradi <videolan # tobias-conradi.de>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCPlaybackService.h"

@class VLCPlaybackService;
@class VLCServices;

extern NSString *const VLCPlayerDisplayControllerDisplayMiniPlayer;
extern NSString *const VLCPlayerDisplayControllerHideMiniPlayer;

typedef NS_ENUM(NSUInteger, VLCPlayerDisplayControllerDisplayMode) {
    VLCPlayerDisplayControllerDisplayModeFullscreen,
    VLCPlayerDisplayControllerDisplayModeMiniplayer,
};

@protocol VLCMiniPlaybackViewInterface <NSObject>

@required;
@property (nonatomic) BOOL visible;

@end

@protocol VLCPlayerDisplayControllerDelegate

@end

@protocol VLCMiniPlayer;

@interface VLCPlayerDisplayController : UIViewController

@property (nonatomic, assign) VLCPlayerDisplayControllerDisplayMode displayMode;
@property (nonatomic, weak, nullable) VLCPlaybackService *playbackController;
@property (nonatomic, strong, nullable) NSLayoutYAxisAnchor *realBottomAnchor;
@property (nonatomic, readonly) BOOL isMiniPlayerVisible;
@property (nonatomic, strong, nullable) UIView *miniPlaybackView;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                                 bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_UNAVAILABLE;

- (nullable instancetype)initWithServices:(nullable id)services NS_DESIGNATED_INITIALIZER;

- (void)showFullscreenPlayback;
- (void)closeFullscreenPlayback;

- (void)pushPlaybackView;
- (void)dismissPlaybackView;

- (void)hintPlayqueueWithDelay:(NSTimeInterval)delay;

@end
