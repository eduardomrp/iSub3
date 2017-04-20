//
//  SUSServerPlaylist.m
//  iSub
//
//  Created by Benjamin Baron on 11/6/11.
//  Copyright (c) 2011 Ben Baron. All rights reserved.
//

#import "SUSServerPlaylist.h"

@implementation SUSServerPlaylist

- (id)initWithTBXMLElement:(TBXMLElement *)element
{
	if ((self = [super init]))
	{
		_playlistId = [TBXML valueOfAttributeNamed:@"id" forElement:element];
		_playlistName = [[TBXML valueOfAttributeNamed:@"name" forElement:element] cleanString];
	}
	
	return self;
}

- (id)initWithRXMLElement:(RXMLElement *)element
{
    if ((self = [super init]))
    {
        _playlistId = [element attribute:@"id"];
        _playlistName = [[element attribute:@"name"] cleanString];
    }
    
    return self;
}

-(id)copyWithZone: (NSZone *) zone
{
    SUSServerPlaylist *playlist = [[SUSServerPlaylist alloc] init];
    playlist.playlistName = self.playlistName;
    playlist.playlistId = self.playlistId;
    return playlist;
}

- (NSComparisonResult)compare:(SUSServerPlaylist *)otherObject 
{
    return [self.playlistName caseInsensitiveCompare:otherObject.playlistName];
}


@end
