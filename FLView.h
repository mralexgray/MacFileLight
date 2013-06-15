/* Copyright (C) 1996 Dave Vasilevsky
 * This file is licensed under the GNU General Public License,
 * see the file Copying.txt for details. */

#import "FLRadialPainter.h"
#import "FLFile.h"

@interface FLView : NSView <FLHasDataSource>
{
    FLRadialPainter 		*m_painter;
    NSTrackingRectTag 	m_trackingRect;
    BOOL 					m_wasAcceptingMouseEvents;
    FLFile 					*m_context_target;
}
@property (assign) IBOutlet NSImageView *iconDisplay;
@property (assign) IBOutlet id locationDisplay;
@property (assign) IBOutlet id sizeDisplay;
@property (assign) IBOutlet id dataSource;
@property (assign) IBOutlet id controller;
@property (assign) IBOutlet id contextMenu;

- (IBAction) zoom: 		(id) sender;
- (IBAction) open: 		(id) sender;
- (IBAction) reveal: 	(id) sender;
- (IBAction) trash: 		(id) sender;
- (IBAction) copyPath: 	(id) sender;

@end
