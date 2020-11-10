//
//  Song.h
//  iSub
//
//  Created by Ben Baron on 2/28/10.
//  Copyright 2010 Ben Baron. All rights reserved.
//

#import "ISMSMediaItem.h"

@interface ISMSSong : NSObject <NSCoding, NSCopying, ISMSMediaItem>

@property (copy) NSString *title;
@property (copy) NSString *songId;
@property (copy) NSString *parentId;
@property (copy) NSString *artist;
@property (copy) NSString *album;
@property (copy) NSString *genre;
@property (copy) NSString *coverArtId;
@property (copy) NSString *path;
@property (copy) NSString *suffix;
@property (copy) NSString *transcodedSuffix;
@property (copy) NSNumber *duration;
@property (copy) NSNumber *bitRate;
@property (copy) NSNumber *track;
@property (copy) NSNumber *year;
@property (copy) NSNumber *size;
@property (copy) NSNumber *discNumber;
@property BOOL isVideo;

- (NSString *)localSuffix;
- (NSString *)localPath;
- (NSString *)localTempPath;
- (NSString *)currentPath;
@property (readonly) BOOL isTempCached;
@property (readonly) unsigned long long localFileSize;
@property (readonly) NSUInteger estimatedBitrate;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

- (id)copyWithZone:(NSZone *)zone;

- (id)initWithPMSDictionary:(NSDictionary *)dictionary;
- (id)initWithTBXMLElement:(TBXMLElement *)element;
- (id)initWithRXMLElement:(RXMLElement *)element;
- (id)initWithAttributeDict:(NSDictionary *)attributeDict;

- (BOOL)isEqualToSong:(ISMSSong	*)otherSong;

@end

#import "ISMSSong+DAO.h"