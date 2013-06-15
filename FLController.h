
/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

#import "FLScanner.h"

@interface FLController : NSObject <NSToolbarDelegate>

@property (assign) IBOutlet id sizer;
@property (assign) IBOutlet id tabView;
@property (assign) IBOutlet id progress;
@property (assign) IBOutlet id scanDisplay;
@property (assign) IBOutlet id window;
@property (assign) IBOutlet NSImageView *iconDisplay;

@property (nonatomic,strong) FLScanner 	*scanner;
@property (nonatomic,strong) FLDirectory 	*scanDir,
														*rootDir;
- (IBAction) cancelScan: (id)sender;
- (IBAction) open: 		 (id)sender;
- (IBAction) refresh:    (id)sender;

@end
