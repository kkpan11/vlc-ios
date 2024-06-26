/*****************************************************************************
* VLCOSOFetcher.m
* VLC for iOS
*****************************************************************************
* Copyright (c) 2015, 2020 VideoLAN. All rights reserved.
* $Id$
*
* Author: Felix Paul Kühne <fkuehne # videolan.org>
*
* Refer to the COPYING file of the official project for license.
*****************************************************************************/

#import "VLCOSOFetcher.h"
#import "VLCSubtitleItem.h"
#import "VLCOpenSubtitlesDownloader.h"

static NSString *VLCOSOFetcherUserAgentKey = @"VLSub 0.9";

@interface VLCOSOFetcher ()
{
    VLCOpenSubtitlesDownloader *_subtitleDownloader;
}

@property (readwrite, nonatomic, copy, nullable) NSString *latestQuery;

@end

@implementation VLCOSOFetcher

- (instancetype)init
{
    self = [super init];

    if (self) {
        _subtitleLanguageCode = @"en";
    }

    return self;
}

- (void)prepareForFetching
{
    _subtitleDownloader = [[VLCOpenSubtitlesDownloader alloc] initWithUserAgent:VLCOSOFetcherUserAgentKey];
    [self searchForAvailableLanguages];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%s: language ID '%@'", __PRETTY_FUNCTION__, _subtitleLanguageCode];
}

- (void)searchForSubtitlesWithQuery:(nonnull NSString *)query
{
    [_subtitleDownloader setLanguageCode:_subtitleLanguageCode];
    [_subtitleDownloader searchForSubtitlesWithQuery:query :^(NSArray *subtitles, NSError *error){
        if (!subtitles || error) {
            if (self.dataRecipient) {
                if ([self.dataRecipient respondsToSelector:@selector(VLCOSOFetcher:didFailToFindSubtitlesForSearchRequest:)]) {
                    [self.dataRecipient VLCOSOFetcher:self didFailToFindSubtitlesForSearchRequest:query];
                }
            } else
                APLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }

        NSUInteger count = subtitles.count;
        NSMutableArray *subtitlesToReturn = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger x = 0; x < count; x++) {
            OpenSubtitleSearchResult *result = subtitles[x];

            VLCSubtitleItem *item = [[VLCSubtitleItem alloc] init];
            item.ID = result.subtitleID;
            item.name = result.subtitleName;
            item.language = result.subtitleLanguage;
            item.fps = [NSString stringWithFormat:@"%@", result.subtitleFPS];
            item.hd = result.subtitleIsHD;
            item.rating = [NSString stringWithFormat:@"%@", result.subtitleRating];
            item.downloadCount = [NSString stringWithFormat:@"%@", result.subtitleTotalDownloadCount];
            item.uploadDate = result.subtitleUploadDate;

            [subtitlesToReturn addObject:item];
        }

        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uploadDate" ascending:NO];
        [subtitlesToReturn sortUsingDescriptors:@[dateDescriptor]];

        if (self.dataRecipient) {
            if ([self.dataRecipient respondsToSelector:@selector(VLCOSOFetcher:didFindSubtitles:forSearchRequest:)]) {
                [self.dataRecipient VLCOSOFetcher:self didFindSubtitles:[subtitlesToReturn copy] forSearchRequest:query];
            }
        } else
            APLog(@"found %@", subtitlesToReturn);
     }];
}

- (void)searchForAvailableLanguages
{
    [_subtitleDownloader supportedLanguagesList:^(NSArray *languages, NSError *aError){
        if (!languages || aError) {
            APLog(@"%s: no languages found or error %@", __PRETTY_FUNCTION__, aError);
        }

        NSUInteger count = languages.count;
        NSMutableArray *languageItems = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger x = 0; x < count; x++) {
            OpenSubtitleLanguageResult *result = languages[x];

            VLCSubtitleLanguage *item = [[VLCSubtitleLanguage alloc] init];
            item.languageCode = result.languageCode;
            item.languageName = result.languageName;

            [languageItems addObject:item];
        }

        self->_availableLanguages = [languageItems copy];

        if (self.dataRecipient) {
            if ([self.dataRecipient respondsToSelector:@selector(VLCOSOFetcherReadyToSearch:)]) {
                [self.dataRecipient VLCOSOFetcherReadyToSearch:self];
            }
        }
    }];
}

- (void)downloadSubtitleItem:(nonnull VLCSubtitleItem *)item toDirectory:(nonnull NSURL *)directory
{
    OpenSubtitleSearchResult *result = [[OpenSubtitleSearchResult alloc] init];
    result.subtitleID = item.ID;

    [_subtitleDownloader downloadSubtitlesForResult:result toDirectory:directory :^(NSURL *location, NSError *error) {
        if (self.dataRecipient) {
            if (error) {
                if ([self.dataRecipient respondsToSelector:@selector(VLCOSOFetcher:didFailToDownloadForItem:withError:)]) {
                    [self.dataRecipient VLCOSOFetcher:self didFailToDownloadForItem:item withError:error];
                }
            } else {
                NSString *path = [location path];

                if ([self.dataRecipient respondsToSelector:@selector(VLCOSOFetcher:subtitleDownloadSucceededForItem:atPath:)]) {
                    [self.dataRecipient VLCOSOFetcher:self subtitleDownloadSucceededForItem:item atPath:path];
                }
            }
        } else
            APLog(@"%s: path %@ error %@", __PRETTY_FUNCTION__, directory, error);
    }];
}

@end
