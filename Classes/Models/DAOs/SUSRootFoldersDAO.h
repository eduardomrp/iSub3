//
//  SUSRootFoldersDAO.h
//  iSub
//
//  Created by Ben Baron on 8/21/11.
//  Copyright 2011 Ben Baron. All rights reserved.
//

#import "ISMSLoaderManager.h"

@class ISMSArtist, FMDatabase, ISMSRootFoldersLoader;

@interface SUSRootFoldersDAO : NSObject <ISMSLoaderManager, ISMSLoaderDelegate>
{		
	NSUInteger _tempRecordCount;
    NSArray *_indexNames;
    NSArray *_indexPositions;
    NSArray *_indexCounts;
}

@property (weak) id<ISMSLoaderDelegate> delegate;

@property (strong) ISMSRootFoldersLoader *loader;

@property (readonly) NSUInteger count;
@property (readonly) NSUInteger searchCount;
@property (readonly) NSArray *indexNames;
@property (readonly) NSArray *indexPositions;
@property (readonly) NSArray *indexCounts;

- (NSString *)tableModifier;

@property (strong) NSNumber *selectedFolderId;
@property (readonly) BOOL isRootFolderIdCached;

+ (void)setFolderDropdownFolders:(NSDictionary *)folders;
+ (NSDictionary *)folderDropdownFolders;

- (id)initWithDelegate:(id <ISMSLoaderDelegate>)theDelegate;

- (ISMSArtist *)artistForPosition:(NSUInteger)position;
- (void)clearSearchTable;
- (void)searchForFolderName:(NSString *)name;
- (ISMSArtist *)artistForPositionInSearch:(NSUInteger)position;

- (void)startLoad;
- (void)cancelLoad;

@end
