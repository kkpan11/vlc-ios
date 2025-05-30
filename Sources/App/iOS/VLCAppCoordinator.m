/*****************************************************************************
 * VLCAppCoordinator.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2022-2024 VideoLAN. All rights reserved.
 * $Id$
 *
 * Author: Felix Paul Kühne <fkuehne # videolan.org>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCAppCoordinator.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "VLCRemoteControlService.h"
#import "VLCFavoriteService.h"
#import "VLCStripeController.h"
#import "VLC-Swift.h"

@interface VLCAppCoordinator()
{
    MediaLibraryService *_mediaLibraryService;
    VLCFavoriteService *_favoriteService;
    VLCHTTPUploaderController *_httpUploaderController;
    VLCBottomTabBarController *_tabBarController;
    TabBarCoordinator *_tabCoordinator;
    VLCPlayerDisplayController *_playerDisplayController;
    VLCRemoteControlService *_remoteControlService;
    UIWindow *_externalWindow;
    VLCStripeController *_stripeController;

#if TARGET_OS_IOS
    VLCRendererDiscovererManager *_rendererDiscovererManager;
#endif
}

@end

@implementation VLCAppCoordinator

+ (instancetype)sharedInstance
{
    static VLCAppCoordinator *sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedInstance = [VLCAppCoordinator new];
    });

    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [VLCLibrary setSharedEventsConfiguration:[VLCEventsLegacyConfiguration new]];
            [self initializeServices];
        });
    }
    return self;
}

- (void)initializeServices
{
    // Init the HTTP Server and clean its cache
    _httpUploaderController = [[VLCHTTPUploaderController alloc] init];
    [_httpUploaderController cleanCache];
    _httpUploaderController.medialibrary = self.mediaLibraryService;

    // start the remote control service
    _remoteControlService = [[VLCRemoteControlService alloc] init];
}

- (MediaLibraryService *)mediaLibraryService
{
    if (!_mediaLibraryService) {
        _mediaLibraryService = [[MediaLibraryService alloc] init];
    }
    return _mediaLibraryService;
}

- (VLCFavoriteService *)favoriteService
{
    if (!_favoriteService) {
        _favoriteService = [[VLCFavoriteService alloc] init];
    }

    return _favoriteService;
}

#if TARGET_OS_IOS
- (VLCRendererDiscovererManager *)rendererDiscovererManager
{
    if (!_rendererDiscovererManager) {
        _rendererDiscovererManager = [[VLCRendererDiscovererManager alloc] initWithPresentingViewController:nil];
    }

    return _rendererDiscovererManager;
}
#endif

- (VLCHTTPUploaderController *)httpUploaderController
{
    if (!_httpUploaderController) {
        [self initializeServices];
    }
    return _httpUploaderController;
}

- (void)setExternalWindow:(UIWindow *)externalWindow
{
    _externalWindow = externalWindow;
}

- (UIWindow *)externalWindow
{
#if TARGET_OS_IOS
    if (@available(iOS 13.0, *)) {
        return _externalWindow;
    } else {
        NSArray *screens = UIScreen.screens;
        if (screens.count <= 1)
            return nil;

        UIScreen *externalScreen = screens[1];
        externalScreen.overscanCompensation = UIScreenOverscanCompensationNone;

        _externalWindow = [[UIWindow alloc] initWithFrame:externalScreen.bounds];
        _externalWindow.rootViewController = [[VLCExternalDisplayController alloc] initWithNibName:nil bundle:nil];
        _externalWindow.screen = externalScreen;
        [_externalWindow makeKeyAndVisible];
    }
#endif
    return _externalWindow;
}

- (void)setTabBarController:(VLCBottomTabBarController *)tabBarController
{
    _tabBarController = tabBarController;
    _tabCoordinator = [[TabBarCoordinator alloc] initWithTabBarController:_tabBarController mediaLibraryService:self.mediaLibraryService];

    _playerDisplayController = [[VLCPlayerDisplayController alloc] init];
    [_tabBarController.view addSubview:_playerDisplayController.view];
    _playerDisplayController.view.layoutMargins = UIEdgeInsetsMake(0, 0, tabBarController.tabBar.frame.size.height, 0);
    _playerDisplayController.realBottomAnchor = tabBarController.tabBar.topAnchor;

    if (@available(iOS 18.0, *)) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            // Adjust the margins and the constraint to the previous tab bar appearance on iPadOS
            _playerDisplayController.view.layoutMargins = UIEdgeInsetsMake(0, 0, tabBarController.bottomBar.frame.size.height, 0);
            _playerDisplayController.realBottomAnchor = tabBarController.bottomBar.topAnchor;
        }
    }

    [_playerDisplayController didMoveToParentViewController:tabBarController];
}

- (VLCBottomTabBarController*)tabBarController
{
    return _tabBarController;
}

- (void)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem
{
    [_tabCoordinator handleShortcutItem:shortcutItem];
}

- (VLCMLMedia *)mediaForUserActivity:(NSUserActivity *)userActivity
{
    VLCMLIdentifier identifier = 0;
    NSDictionary *userInfo = userActivity.userInfo;

    if (userActivity.activityType == CSSearchableItemActionType) {
        identifier = [userInfo[CSSearchableItemActivityIdentifier] integerValue];
    } else {
        identifier = [userInfo[@"playingmedia"] integerValue];
    }

    if (identifier > 0) {
        return [self.mediaLibraryService mediaFor:identifier];
    }

    return nil;
}

- (VLCStripeController *)stripeController
{
    if (!_stripeController) {
        _stripeController = [[VLCStripeController alloc] init];
    }
    return _stripeController;
}

@end
