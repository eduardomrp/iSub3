//
//  SUSServerShuffleLoader.m
//  libSub
//
//  Created by Justin Hill on 2/6/13.
//  Copyright (c) 2013 Einstein Times Two Software. All rights reserved.
//

#import "SUSServerShuffleLoader.h"
#import "SearchXMLParser.h"
#import "NSMutableURLRequest+SUS.h"

@implementation SUSServerShuffleLoader

- (ISMSLoaderType)type {
    return ISMSLoaderType_ServerShuffle;
}

- (NSURLRequest *)createRequest {
    // Start the 100 record open search to create shuffle list
    NSMutableDictionary *parameters = [@{@"size": @"100"} mutableCopy];
    if (self.folderId) {
        if ([self.folderId intValue] >= 0) {
            parameters[@"musicFolderId"] = n2N([self.folderId stringValue]);
        }
    }
    
    return [NSMutableURLRequest requestWithSUSAction:@"getRandomSongs" parameters:parameters];
}

- (void)processResponse {
    // TODO: Refactor this with RaptureXML
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:self.receivedData];
    SearchXMLParser *parser = (SearchXMLParser*)[[SearchXMLParser alloc] initXMLParser];
    [xmlParser setDelegate:parser];
    [xmlParser parse];
    
    if (settingsS.isJukeboxEnabled) {
        [databaseS resetJukeboxPlaylist];
        [jukeboxS jukeboxClearRemotePlaylist];
    } else {
        [databaseS resetCurrentPlaylistDb];
    }
    
    for (ISMSSong *aSong in parser.listOfSongs) {
        [aSong addToCurrentPlaylistDbQueue];
    }
    
    playlistS.isShuffle = NO;    
    
    [NSNotificationCenter postNotificationToMainThreadWithName:ISMSNotification_CurrentPlaylistSongsQueued];
    [self informDelegateLoadingFinished];
}

@end