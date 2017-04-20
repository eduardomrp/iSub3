//
//  Artist.h
//  iSub
//
//  Created by Ben Baron on 2/27/10.
//  Copyright 2010 Ben Baron. All rights reserved.
//

@interface ISMSArtist : NSObject <NSCoding, NSCopying>

@property (copy) NSString *name;
@property (copy) NSString *artistId;

+ (ISMSArtist *) artistWithName:(NSString *)theName andArtistId:(NSString *)theId;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

- (id)initWithAttributeDict:(NSDictionary *)attributeDict;

- (id)initWithTBXMLElement:(TBXMLElement *)element;
- (id)initWithRXMLElement:(RXMLElement *)element;

@end
