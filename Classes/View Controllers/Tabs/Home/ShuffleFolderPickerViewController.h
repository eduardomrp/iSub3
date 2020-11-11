//
//  ShuffleFolderPickerViewController.h
//  iSub
//
//  Created by Ben Baron on 4/6/11.
//  Copyright 2011 Ben Baron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderPickerDialog.h"
#import "NewHomeViewController.h"

@interface ShuffleFolderPickerViewController : UITableViewController

@property (strong) NSMutableArray *sortedFolders;
@property (weak) FolderPickerDialog *myDialog;

@end
