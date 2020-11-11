//
//  SearchAllViewController.h
//  iSub
//
//  Created by Ben Baron on 4/6/11.
//  Copyright 2011 Ben Baron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAllViewController : UITableViewController

@property (strong) NSMutableArray *cellNames;
@property (strong) NSArray *listOfArtists;
@property (strong) NSArray *listOfAlbums;
@property (strong) NSArray *listOfSongs;
@property (strong) NSString *query;

@end
