/*****************************************************************************
* SettingsSection.swift
* VLC for iOS
*****************************************************************************
* Copyright (c) 2020-2023 VideoLAN. All rights reserved.
*
* Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
*          Soomin Lee < bubu@mikan.io >
*          Edgar Fouillet <vlc # edgar.fouillet.eu>
*          Diogo Simao Marques <dogo@videolabs.io>
*          Felix Paul Kühne <fkuehne # videolan.org>
*          Eshan Singh <eeeshan789@icloud.com>
*
* Refer to the COPYING file of the official project for license.
*****************************************************************************/

import Foundation
import LocalAuthentication

// MARK: - SettingsItem
struct SettingsItem: Equatable {
    let title: String
    let subtitle: String?
    let action: Action
    let isTitleEmphasized: Bool

    @available(*, deprecated, message: "access from self.action")
    var preferenceKey: String? {
        switch action {
        case .toggle(let preferenceKey, _):
            return preferenceKey
        case .showActionSheet(_, let preferenceKey, _):
            return preferenceKey
        default:
            return nil
        }
    }

    init(title: String, subtitle: String?, action: Action, isTitleEmphasized: Bool = false) {
        self.title = Self.localizedTitle(key: title)
        self.subtitle = subtitle.flatMap(Self.localizedTitle(key:))
        self.action = action
        self.isTitleEmphasized = isTitleEmphasized
    }

    static func toggle(title: String, subtitle: String?, preferenceKey: String) -> Self {
        let isOn = UserDefaults.standard.bool(forKey: preferenceKey)
        return Self.init(title: title, subtitle: subtitle, action: .toggle(preferenceKey: preferenceKey, isOn: isOn))
    }

    enum Action: Equatable {
        case isLoading
        case toggle(preferenceKey: String, isOn: Bool)
        case showActionSheet(title: String, preferenceKey: String, hasInfo: Bool)
        case donation
        case openPrivacySettings
        case forceRescanAlert
        case exportMediaLibrary
        case displayResetAlert
    }
}

// MARK: - SettingsSection
struct SettingsSection: Equatable {
    let title: String?
    let items: [SettingsItem]

    var isEmpty: Bool {
        items.isEmpty
    }

    static func sections(isLabActivated: Bool, isBackingUp: Bool, isForwardBackwardEqual: Bool, isTapSwipeEqual: Bool) -> [SettingsSection] {
        [
            MainOptions.section(),
            DonationOptions.section(),
            GenericOptions.section(),
            PrivacyOptions.section(),
            GestureControlOptions.section(isForwardBackwardEqual: isForwardBackwardEqual, isTapSwipeEqual: isTapSwipeEqual),
            VideoOptions.section(),
            SubtitlesOptions.section(),
            AudioOptions.section(),
            CastingOptions.section(),
            MediaLibraryOptions.section(isBackingUp: isBackingUp),
            NetworkOptions.section(),
            Lab.section(isLabActivated: isLabActivated),
            Reset.section()
        ].compactMap { $0 }
    }
}

// MARK: - MainOptions
enum MainOptions {
    static var privacy: SettingsItem {
        .init(
            title: "SETTINGS_PRIVACY_TITLE",
            subtitle: "SETTINGS_PRIVACY_SUBTITLE",
            action: .openPrivacySettings
        )
    }

    static var appearance: SettingsItem {
        let k = kVLCSettingAppTheme
        return .init(
            title: "SETTINGS_DARKTHEME",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_DARKTHEME", preferenceKey: k, hasInfo: false)
        )
    }

    static func section() -> SettingsSection? {
        .init(title: nil, items: [
            privacy,
            appearance
        ])
    }
}

// MARK: - DonationOptions
enum DonationOptions {
    static var donate: SettingsItem {
        .init(
            title: "SETTINGS_DONATE",
            subtitle: "SETTINGS_DONATE_LONG",
            action: .donation
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_DONATE_TITLE", items: [donate])
    }
}

// MARK: - GenericOptions
enum GenericOptions {
    static var defaultPlaybackSpeed: SettingsItem {
        let k = kVLCSettingPlaybackSpeedDefaultValue
        return .init(
            title: "SETTINGS_PLAYBACK_SPEED_DEFAULT",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_PLAYBACK_SPEED_DEFAULT", preferenceKey: k, hasInfo: false)
        )
    }

    static var continueAudioPlayback: SettingsItem {
        let k = kVLCSettingContinueAudioPlayback
        return .init(
            title: "SETTINGS_CONTINUE_AUDIO_PLAYBACK",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_CONTINUE_AUDIO_PLAYBACK", preferenceKey: k, hasInfo: true)
        )
    }

    static var playVideoInFullScreen: SettingsItem {
        .toggle(
            title: "SETTINGS_VIDEO_FULLSCREEN",
            subtitle: nil,
            preferenceKey: kVLCSettingVideoFullscreenPlayback
        )
    }

    static var continueVideoPlayback: SettingsItem {
        let k = kVLCSettingContinuePlayback
        return .init(
            title: "SETTINGS_CONTINUE_VIDEO_PLAYBACK",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_CONTINUE_VIDEO_PLAYBACK", preferenceKey: k, hasInfo: true)
        )
    }

    static var automaticallyPlayNextItem: SettingsItem {
        let k = kVLCAutomaticallyPlayNextItem
        return .init(
            title: "SETTINGS_NETWORK_PLAY_ALL",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_NETWORK_PLAY_ALL", preferenceKey: k, hasInfo: false)
        )
    }

    static var enableTextScrollingInMediaList: SettingsItem {
        .toggle(
            title: "SETTINGS_ENABLE_MEDIA_CELL_TEXT_SCROLLING",
            subtitle: nil,
            preferenceKey: kVLCSettingEnableMediaCellTextScrolling
        )
    }

    static var rememberPlayerState: SettingsItem {
        .toggle(
            title: "SETTINGS_REMEMBER_PLAYER_STATE",
            subtitle: nil,
            preferenceKey: kVLCPlayerShouldRememberState
        )
    }

    static var restoreLastPlayedMedia: SettingsItem {
        .toggle(
            title: "SETTINGS_RESTORE_LAST_PLAYED_MEDIA",
            subtitle: nil,
            preferenceKey: kVLCRestoreLastPlayedMedia
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_GENERIC_TITLE", items: [
            defaultPlaybackSpeed,
            continueAudioPlayback,
            playVideoInFullScreen,
            continueVideoPlayback,
            automaticallyPlayNextItem,
            enableTextScrollingInMediaList,
            rememberPlayerState,
            restoreLastPlayedMedia
        ])
    }

}

// MARK: - PrivacyOptions
enum PrivacyOptions {
    static var passcodeLock: SettingsItem {
        .toggle(
            title: "SETTINGS_PASSCODE_LOCK",
            subtitle: "SETTINGS_PASSCODE_LOCK_SUBTITLE",
            preferenceKey: kVLCSettingPasscodeOnKey
        )
    }

    static var enableBiometrics: SettingsItem? {
        let authContext = LAContext()

        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            switch authContext.biometryType {
            case .touchID:
                return .toggle(
                    title: "SETTINGS_PASSCODE_LOCK_ALLOWTOUCHID",
                    subtitle: nil,
                    preferenceKey: kVLCSettingPasscodeAllowTouchID
                )
            case .faceID:
                return .toggle(
                    title: "SETTINGS_PASSCODE_LOCK_ALLOWFACEID",
                    subtitle: nil,
                    preferenceKey: kVLCSettingPasscodeAllowFaceID
                )
            case .none:
                fallthrough
            @unknown default:
                return nil
            }
        }

        return nil
    }

    static var hideLibraryInFilesApp: SettingsItem {
        .toggle(
            title: "SETTINGS_HIDE_LIBRARY_IN_FILES_APP",
            subtitle: "SETTINGS_HIDE_LIBRARY_IN_FILES_APP_SUBTITLE",
            preferenceKey: kVLCSettingHideLibraryInFilesApp
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_PRIVACY_TITLE", items: [
            passcodeLock,
            enableBiometrics,
            hideLibraryInFilesApp
        ].compactMap({$0}))
    }
}

// MARK: - GestureControlOptions
enum GestureControlOptions {
    static var swipeUpDownForVolume: SettingsItem {
        .toggle(
            title: "SETTINGS_GESTURES_VOLUME",
            subtitle: nil,
            preferenceKey: kVLCSettingVolumeGesture
        )
    }

    static var twoFingerTap: SettingsItem {
        .toggle(
            title: "SETTINGS_GESTURES_PLAYPAUSE",
            subtitle: nil,
            preferenceKey: kVLCSettingPlayPauseGesture
        )
    }

    static var swipeUpDownForBrightness: SettingsItem {
        .toggle(
            title: "SETTINGS_GESTURES_BRIGHTNESS",
            subtitle: nil,
            preferenceKey: kVLCSettingBrightnessGesture
        )
    }

    static var swipeRightLeftToSeek: SettingsItem {
        .toggle(
            title: "SETTINGS_GESTURES_SEEK",
            subtitle: nil,
            preferenceKey: kVLCSettingSeekGesture
        )
    }

    static var pinchToClose: SettingsItem {
        .toggle(
            title: "SETTINGS_GESTURES_CLOSE",
            subtitle: nil,
            preferenceKey: kVLCSettingCloseGesture
        )
    }

    static var forwardBackwardEqual: SettingsItem {
        .toggle(
            title: "SETTINGS_GESTURES_FORWARD_BACKWARD_EQUAL",
            subtitle: nil,
            preferenceKey: kVLCSettingPlaybackForwardBackwardEqual
        )
    }

    static var tapSwipeEqual: SettingsItem {
        .toggle(
            title: "SETTINGS_GESTURES_TAP_SWIPE_EQUAL",
            subtitle: nil,
            preferenceKey: kVLCSettingPlaybackTapSwipeEqual
        )
    }

    static var forwardSkipLength: SettingsItem {
        let k = kVLCSettingPlaybackForwardSkipLength
        return .init(
            title: dynamicForwardSkipDescription(),
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: dynamicForwardSkipDescription(), preferenceKey: k, hasInfo: false)
        )
    }

    static var backwardSkipLength: SettingsItem {
        let k = kVLCSettingPlaybackBackwardSkipLength
        return .init(
            title: dynamicBackwardSkipDescription(),
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: dynamicBackwardSkipDescription(), preferenceKey: k, hasInfo: false)
        )
    }

    static var forwardSkipLengthSwipe: SettingsItem {
        let k = kVLCSettingPlaybackForwardSkipLengthSwipe
        return .init(
            title: dynamicForwardSwipeDescription(),
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: dynamicForwardSwipeDescription(), preferenceKey: k, hasInfo: false)
        )
    }

    static var backwardSkipLengthSwipe: SettingsItem {
        let k = kVLCSettingPlaybackBackwardSkipLengthSwipe
        return .init(
            title: "SETTINGS_PLAYBACK_SKIP_BACKWARD_SWIPE",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_PLAYBACK_SKIP_BACKWARD_SWIPE", preferenceKey: k, hasInfo: false)
        )
    }

    static var longTouchToSpeedUp: SettingsItem {
        .toggle(
            title: "SETINGS_LONG_TOUCH_SPEED_UP",
            subtitle: nil,
            preferenceKey: kVLCSettingPlaybackLongTouchSpeedUp
        )
    }

    static func section(isForwardBackwardEqual: Bool, isTapSwipeEqual: Bool) -> SettingsSection? {
        .init(title: "SETTINGS_GESTURES", items: [
            swipeUpDownForVolume,
            twoFingerTap,
            swipeUpDownForBrightness,
            swipeRightLeftToSeek,
            pinchToClose,
            forwardBackwardEqual,
            tapSwipeEqual,
            forwardSkipLength,
            isForwardBackwardEqual ? nil : backwardSkipLength,
            isTapSwipeEqual ? nil : forwardSkipLengthSwipe,
            (isTapSwipeEqual || isForwardBackwardEqual) ? nil : backwardSkipLengthSwipe,
            longTouchToSpeedUp
        ].compactMap({$0}))
    }

    private static func dynamicForwardSkipDescription() -> String {
        let forwardBackwardEqual = UserDefaults.standard.bool(forKey: kVLCSettingPlaybackForwardBackwardEqual)
        let tapSwipeEqual = UserDefaults.standard.bool(forKey: kVLCSettingPlaybackTapSwipeEqual)

        if forwardBackwardEqual && tapSwipeEqual {
            return "SETTINGS_PLAYBACK_SKIP_GENERIC"
        } else if forwardBackwardEqual && !tapSwipeEqual {
            return "SETTINGS_PLAYBACK_SKIP_TAP"
        } else if !forwardBackwardEqual && !tapSwipeEqual {
            return "SETTINGS_PLAYBACK_SKIP_FORWARD_TAP"
        } else {
            return "SETTINGS_PLAYBACK_SKIP_FORWARD"
        }
    }

    private static func dynamicBackwardSkipDescription() -> String {
        let tapSwipeEqual = UserDefaults.standard.bool(forKey: kVLCSettingPlaybackTapSwipeEqual)

        if tapSwipeEqual {
            return "SETTINGS_PLAYBACK_SKIP_BACKWARD"
        } else {
            return "SETTINGS_PLAYBACK_SKIP_BACKWARD_TAP"
        }
    }

    private static func dynamicForwardSwipeDescription() -> String {
        let forwardBackwardEqual = UserDefaults.standard.bool(forKey: kVLCSettingPlaybackForwardBackwardEqual)

        if forwardBackwardEqual {
            return "SETTINGS_PLAYBACK_SKIP_SWIPE"
        } else {
            return "SETTINGS_PLAYBACK_SKIP_FORWARD_SWIPE"
        }
    }
}

// MARK: - VideoOptions
enum VideoOptions {
    static var deBlockingFilter: SettingsItem {
        let k = kVLCSettingSkipLoopFilter
        return .init(
            title: "SETTINGS_SKIP_LOOP_FILTER",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_SKIP_LOOP_FILTER", preferenceKey: k, hasInfo: true)
        )
    }

    static var deInterlace: SettingsItem {
        let k = kVLCSettingDeinterlace
        return .init(
            title: "SETTINGS_DEINTERLACE",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_DEINTERLACE", preferenceKey: k, hasInfo: true)
        )
    }

    static var hardwareDecoding: SettingsItem {
        let k = kVLCSettingHardwareDecoding
        return .init(
            title: "SETTINGS_HWDECODING",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_HWDECODING", preferenceKey: k, hasInfo: true)
        )
    }

    static var rememberPlayerBrightness: SettingsItem {
        .toggle(
            title: "SETTINGS_REMEMBER_PLAYER_BRIGHTNESS",
            subtitle: nil,
            preferenceKey: kVLCPlayerShouldRememberBrightness
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_VIDEO_TITLE", items: [
            deBlockingFilter,
            deInterlace,
            hardwareDecoding,
            rememberPlayerBrightness
        ])
    }
}

// MARK: - SubtitlesOptions
enum SubtitlesOptions {
    static var disableSubtitles: SettingsItem {
        .toggle(
            title: "SETTINGS_SUBTITLES_DISABLE",
            subtitle: "SETTINGS_SUBTITLES_DISABLE_LONG",
            preferenceKey: kVLCSettingDisableSubtitles
        )
    }

    static var font: SettingsItem {
        let k = kVLCSettingSubtitlesFont
        return .init(
            title: "SETTINGS_SUBTITLES_FONT",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_SUBTITLES_FONT", preferenceKey: k, hasInfo: true)
        )
    }

    static var relativeFontSize: SettingsItem {
        let k = kVLCSettingSubtitlesFontSize
        return .init(
            title: "SETTINGS_SUBTITLES_FONTSIZE",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_SUBTITLES_FONTSIZE", preferenceKey: k, hasInfo: true)
        )
    }

    static var useBoldFont: SettingsItem {
        .toggle(
            title: "SETTINGS_SUBTITLES_BOLDFONT",
            subtitle: nil,
            preferenceKey: kVLCSettingSubtitlesBoldFont
        )
    }

    static var fontColor: SettingsItem {
        let k = kVLCSettingSubtitlesFontColor
        return .init(
            title: "SETTINGS_SUBTITLES_FONTCOLOR",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_SUBTITLES_FONTCOLOR", preferenceKey: k, hasInfo: true)
        )
    }

    static var textEncoding: SettingsItem {
        let k = kVLCSettingTextEncoding
        return .init(
            title: "SETTINGS_SUBTITLES_TEXT_ENCODING",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_SUBTITLES_TEXT_ENCODING", preferenceKey: k, hasInfo: true)
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_SUBTITLES_TITLE", items: [
            disableSubtitles,
            font,
            relativeFontSize,
            useBoldFont,
            fontColor,
            textEncoding
        ])
    }
}

// MARK: - CastingOptions
enum CastingOptions {
    static var audioPassThrough: SettingsItem {
        .toggle(
            title: "SETTINGS_PTCASTING",
            subtitle: "SETTINGS_PTCASTINGLONG",
            preferenceKey: kVLCSettingCastingAudioPassthrough
        )
    }

    static var conversionQuality: SettingsItem {
        let k = kVLCSettingCastingConversionQuality
        return .init(
            title: "SETTINGS_CASTING_CONVERSION_QUALITY",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_CASTING_CONVERSION_QUALITY", preferenceKey: k, hasInfo: false)
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_CASTING", items: [
            audioPassThrough,
            conversionQuality
        ])
    }
}

// MARK: - AudioOptions
enum AudioOptions {
    static var preampLevel: SettingsItem {
        let k = kVLCSettingDefaultPreampLevel
        return .init(
            title: "SETTINGS_AUDIO_PREAMP_LEVEL",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_AUDIO_PREAMP_LEVEL", preferenceKey: k, hasInfo: false)
        )
    }

    static var timeStretchingAudio: SettingsItem {
        .toggle(
            title: "SETTINGS_TIME_STRETCH_AUDIO",
            subtitle: "SETTINGS_TIME_STRETCH_AUDIO_LONG",
            preferenceKey: kVLCSettingStretchAudio
        )
    }

    static var audioPlaybackInBackground: SettingsItem {
        .toggle(
            title: "SETTINGS_BACKGROUND_AUDIO",
            subtitle: nil,
            preferenceKey: kVLCSettingContinueAudioInBackgroundKey
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_AUDIO_TITLE", items: [
            preampLevel,
            timeStretchingAudio,
            audioPlaybackInBackground
        ])
    }
}

// MARK: - MediaLibraryOptions
enum MediaLibraryOptions {
    static var forceVLCToRescanTheMediaLibrary: SettingsItem {
        .init(
            title: "SETTINGS_MEDIA_LIBRARY_RESCAN",
            subtitle: nil,
            action: .forceRescanAlert,
            isTitleEmphasized: true
        )
    }

    static var optimiseItemNamesForDisplay: SettingsItem {
        .toggle(
            title: "SETTINGS_DECRAPIFY",
            subtitle: nil,
            preferenceKey: kVLCSettingsDecrapifyTitles
        )
    }

    static var disableGrouping: SettingsItem {
        .toggle(
            title: "SETTINGS_DISABLE_GROUPING",
            subtitle: nil,
            preferenceKey: kVLCSettingsDisableGrouping
        )
    }

    static var showVideoThumbnails: SettingsItem {
        .toggle(
            title: "SETTINGS_SHOW_THUMBNAILS",
            subtitle: nil,
            preferenceKey: kVLCSettingShowThumbnails
        )
    }

    static var showAudioArtworks: SettingsItem {
        .toggle(
            title: "SETTINGS_SHOW_ARTWORKS",
            subtitle: nil,
            preferenceKey: kVLCSettingShowArtworks
        )
    }

    static var includeMediaLibInDeviceBackup: SettingsItem {
        .toggle(
            title: "SETTINGS_BACKUP_MEDIA_LIBRARY",
            subtitle: nil,
            preferenceKey: kVLCSettingBackupMediaLibrary
        )
    }

    static var includeMediaLibInDeviceBackupWhenBackingUp: SettingsItem {
        .init(
            title: "SETTINGS_BACKUP_MEDIA_LIBRARY",
            subtitle: nil,
            action: .isLoading
        )
    }

    static func section(isBackingUp: Bool) -> SettingsSection? {
        .init(title: "SETTINGS_MEDIA_LIBRARY", items: [
            forceVLCToRescanTheMediaLibrary,
            optimiseItemNamesForDisplay,
            disableGrouping,
            showVideoThumbnails,
            showAudioArtworks,
            {
                if isBackingUp {
                    return includeMediaLibInDeviceBackupWhenBackingUp
                } else {
                    return includeMediaLibInDeviceBackup
                }
            }()
        ])
    }
}

// MARK: - NetworkOptions
enum NetworkOptions {
    static var networkCachingLevel: SettingsItem {
        let k = kVLCSettingNetworkCaching
        return .init(
            title: "SETTINGS_NETWORK_CACHING_TITLE",
            subtitle: SettingsItem.getSubtitle(for: k),
            action: .showActionSheet(title: "SETTINGS_NETWORK_CACHING_TITLE", preferenceKey: k, hasInfo: true)
        )
    }

    static var ipv6SupportForWiFiSharing: SettingsItem {
        .toggle(
            title: "SETTINGS_WIFISHARING_IPv6",
            subtitle: nil,
            preferenceKey: kVLCSettingWiFiSharingIPv6
        )
    }

    static var forceSMBv1: SettingsItem {
        .toggle(
            title: "SETTINGS_FORCE_SMBV1",
            subtitle: "SETTINGS_FORCE_SMBV1_LONG",
            preferenceKey: kVLCForceSMBV1
        )
    }

    static var rtspctp: SettingsItem {
        .toggle(
            title: "SETTINGS_RTSP_TCP",
            subtitle: nil,
            preferenceKey: kVLCSettingNetworkRTSPTCP
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_NETWORK", items: [
            networkCachingLevel,
            ipv6SupportForWiFiSharing,
            forceSMBv1,
            rtspctp
        ])
    }
}

// MARK: - Lab
enum Lab {
    static var debugLogging: SettingsItem {
        .toggle(
            title: "SETTINGS_DEBUG_LOG",
            subtitle: nil,
            preferenceKey: kVLCSaveDebugLogs
        )
    }

    static var exportLibrary: SettingsItem {
        .init(
            title: "SETTINGS_EXPORT_LIBRARY",
            subtitle: nil,
            action: .exportMediaLibrary
        )
    }

    static func section(isLabActivated: Bool) -> SettingsSection? {
        guard isLabActivated else { return nil }

        return .init(title: "SETTINGS_LAB", items: [
            debugLogging,
            exportLibrary
        ])
    }
}

// MARK: - Reset
enum Reset {
    static var resetOptions: SettingsItem {
        .init(
            title: "SETTINGS_RESET",
            subtitle: nil,
            action: .displayResetAlert
        )
    }

    static func section() -> SettingsSection? {
        .init(title: "SETTINGS_RESET_TITLE", items: [resetOptions])
    }
}

// MARK: - Private
fileprivate extension SettingsItem {
    private static let localizer = NSObject()
    private static let settingsBundle = {
        localizer.getSettingsBundle()!
    }()

    static func localizedTitle(key: String) -> String {
        settingsBundle.localizedString(forKey: key, value: key, table: "Root")
    }

    static func getSubtitle(for preferenceKey: String) -> String? {
        localizer.getSubtitle(for: preferenceKey)
    }
}
