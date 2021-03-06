/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

#import "FLView.h"

#import "FLRadialPainter.h"
#import "FLFile.h"
#import "FLController.h"
#import "FLDirectoryDataSource.h"


@implementation FLView
@synthesize  dataSource, contextMenu, controller, locationDisplay, sizeDisplay, iconDisplay;
#pragma mark Tracking

-    (void) setTrackingRect			{
    NSPoint mouse 	= [self.window mouseLocationOutsideOfEventStream];
    NSPoint where 	= [self convertPoint:mouse fromView: nil];
    BOOL inside 		= ([self hitTest: where] == self);
    m_trackingRect 	= [self addTrackingRect:self.visibleRect owner:self
												userData:NULL 		 assumeInside:inside];
    if (inside)		  [self mouseEntered: nil];
}
-    (void) clearTrackingRect			{	[self removeTrackingRect: m_trackingRect];	}
-    (BOOL) acceptsFirstResponder	{
    return YES;
}
-    (BOOL) becomeFirstResponder		{
    return YES;
}
-    (void) resetCursorRects			{
	[super resetCursorRects];
	[self clearTrackingRect];
	[self setTrackingRect];
}
-    (void) viewWillMoveToWindow:(NSWindow*)win	{
	if (!win && [self window]) {
        [self clearTrackingRect];
    }
}
-    (void) viewDidMoveToWindow						{
	if ([self window]) {
        [self setTrackingRect];
    }
}
-    (void) mouseEntered:  (NSEvent*)event		{
    m_wasAcceptingMouseEvents = [[self window] acceptsMouseMovedEvents];
    [[self window] setAcceptsMouseMovedEvents: YES];
    [[self window] makeFirstResponder: self];
}
- (FLFile*) itemForEvent: 	(NSEvent*)event		{
    NSPoint where = [self convertPoint: [event locationInWindow] fromView: nil];
    return [m_painter itemAt: where];
}
-    (void) mouseExited: 	(NSEvent*)event		{
    [[self window] setAcceptsMouseMovedEvents: m_wasAcceptingMouseEvents];
    [locationDisplay setStringValue: @""];
    [sizeDisplay setStringValue: @""];
}
-    (void) mouseMoved: 	(NSEvent*)event		{
    id item = [self itemForEvent: event];
	 if (item) {
		 [iconDisplay setImage:[item icon]];
		 [locationDisplay setStringValue: [item path]];
        [sizeDisplay setStringValue: [item displaySize]];
        if ([item isKindOfClass: [FLDirectory class]]) {
            [[NSCursor pointingHandCursor] set];
        } else {
            [[NSCursor arrowCursor] set];
        }
    } else {
        [locationDisplay setStringValue: @""];
        [sizeDisplay setStringValue: @""];
        [[NSCursor arrowCursor] set];
    }
}
-    (void) mouseUp: 		(NSEvent*)event		{
    id item = [self itemForEvent: event];
    if (item && [item isKindOfClass: [FLDirectory class]]) {
        [controller setRootDir: item];
    }
}
- (NSMenu*) menuForEvent: 	(NSEvent*)event		{
    id item = [self itemForEvent: event];
    if (item) {
        m_context_target = item;
        return (NSMenu *)contextMenu;
    } else {
        return nil;
    }
}
-    (BOOL) validateMenuItem: (NSMenuItem*)item	{
    return [item action] == @selector(zoom:) ? [m_context_target isKindOfClass: [FLDirectory class]] : YES;
}

- (IBAction) zoom:    (id) sender	{ [controller setRootDir:(FLDirectory*)m_context_target];	}
- (IBAction) open:    (id) sender	{ [NSWorkspace.sharedWorkspace openFile:[m_context_target path]];	}
- (IBAction) reveal:  (id) sender	{ [NSWorkspace.sharedWorkspace selectFile:[m_context_target path]inFileViewerRootedAtPath: @""];	}
- (IBAction) trash:   (id) sender	{
    NSInteger tag;
    BOOL success = [NSWorkspace.sharedWorkspace
        performFileOperation: NSWorkspaceRecycleOperation
                      source: m_context_target.path.stringByDeletingLastPathComponent
                 destination: @""
                       files: @[m_context_target.path.lastPathComponent]
                         tag: &tag];
    
    success ? [controller refresh: self] : NSRunAlertPanel(@"Deletion failed", [NSString stringWithFormat: @"The path %@ could not be deleted.", m_context_target.path], nil, nil, nil);
}
- (IBAction) copyPath:(id) sender	{
    [NSPasteboard.generalPasteboard declareTypes:@[NSStringPboardType] owner:self];
    [NSPasteboard.generalPasteboard setString:[m_context_target path].copy forType:NSStringPboardType];
}

#pragma mark Drawing
- (void) drawSize: (NSString*)str	{

    double rfrac, wantr, haver;
    float pts;
    NSFont *font;
    NSSize size;
    NSDictionary *attrs;
    NSPoint p, center;
    
    rfrac = [m_painter minRadiusFraction] - 0.02;
    wantr = [self maxRadius] * rfrac;
    
    font = [NSFont systemFontOfSize: 0];
    attrs = @{NSFontAttributeName:font}.mutableCopy;
    size = [str sizeWithAttributes: attrs];
    haver = hypot(size.width, size.height) / 2;
    
    pts = [font pointSize] * wantr / haver;
    font = [NSFont systemFontOfSize: pts];
    [attrs setValue: font forKey: NSFontAttributeName];
    size = [str sizeWithAttributes: attrs];
    center = [self center];
    p = NSMakePoint(center.x - size.width / 2, center.y - size.height / 2);
    [str drawAtPoint: p withAttributes: attrs];
}
- (void) drawRect: (NSRect)rect		{

    [m_painter drawRect: rect];
    [self drawSize: [[self.dataSource rootDir] displaySize]];
}
- (void) awakeFromNib					{
    m_painter = [FLRadialPainter.alloc initWithView:self];
    [m_painter setColorer: self];
}
- (NSColor*)colorForItem:(id) item
               angleFrac:(CGFloat)angle
               levelFrac:(CGFloat)level	{
   return [item isKindOfClass:FLDirectory.class]
		? [m_painter colorForItem: item angleFrac: angle levelFrac: level]
		: [NSColor colorWithCalibratedWhite: 0.85 alpha: 1.0];
}

@end
