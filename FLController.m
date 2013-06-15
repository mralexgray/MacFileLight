/* Copyright (C) 1996 Dave Vasilevsky
 This file is licensed under the GNU General Public License, see the file Copying.txt for details. */


#import "FLController.h"
#import "FLDirectoryDataSource.h"

static NSString 	*ToolbarID 					= @"Filelight Toolbar",
						*ToolbarItemUpID 			= @"Up ToolbarItem",
						*ToolbarItemRefreshID 	= @"Refresh ToolbarItem";

@implementation FLController
@synthesize  scanDisplay, sizer, window, progress, tabView, iconDisplay;

#pragma mark Toolbar
- (void) setupToolbar						{    NSToolbar *toolbar;

	toolbar = [NSToolbar.alloc initWithIdentifier: ToolbarID];
   toolbar.allowsUserCustomization	= YES;
	toolbar.autosavesConfiguration	= YES;
	toolbar.delegate  					= self;
	[window setToolbar:toolbar];

}
- (NSToolbarItem*)toolbar: (NSToolbar*) toolbar
      itemForItemIdentifier: (NSString*)   itemID
  willBeInsertedIntoToolbar: (BOOL) 	willInsert					{
    NSToolbarItem *item = [[NSToolbarItem alloc]
        initWithItemIdentifier: itemID];
    
    if ([itemID isEqual: ToolbarItemUpID]) {
        [item setLabel: @"Up"];
        [item setToolTip: @"Go to the parent directory"];
        [item setImage: [NSImage imageNamed: @"arrowUp"]];
        [item setAction: @selector(parentDir:)];
    } else if ([itemID isEqual: ToolbarItemRefreshID]) {
        [item setLabel: @"Refresh"];
        [item setToolTip: @"Rescan the current directory"];
        [item setImage: [NSImage imageNamed: @"reload"]];
        [item setAction: @selector(refresh:)];
    } else {
//        [item release];
        return nil;
    }
    
    if (![item paletteLabel]) {
        [item setPaletteLabel: [item label]];
    }
    if (![item target]) {
        [item setTarget: self];
    }
    return item;//autorelease];
}
- (NSArray*) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar	{
    return @[ToolbarItemUpID,
        ToolbarItemRefreshID];
}
- (NSArray*) toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar	{
    return @[ToolbarItemUpID,
        ToolbarItemRefreshID,
        NSToolbarCustomizeToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier];
}
- (BOOL) validateToolbarItem: (NSToolbarItem *)item {

	return [item.itemIdentifier isEqual:ToolbarItemUpID] ? ![FLScanner isMountPoint:self.rootDir.path] : YES;
}
#pragma mark Scanning
- (BOOL) startScan:(NSString*)path		{
    if (_scanner) return NO;

    [tabView 		selectTabViewItemWithIdentifier: @"Progress"];
    [progress 		setDoubleValue: 			 [progress minValue]];
    [scanDisplay 	setStringValue:								  @""];
    [window 		makeKeyAndOrderFront:						 self];

    return [_scanner = [FLScanner.alloc initWithPath: path progress: progress display: scanDisplay icon:iconDisplay]
										       scanThenPerform: @selector(finishScan:)       on: self], YES;
}
- (void) finishScan:		  (id)data		{

    if ([_scanner scanError]) {
        if (![_scanner isCancelled]) NSRunAlertPanel(@"Directory scan could not complete",[_scanner scanError], nil, nil, nil);
        [window orderOut: self];
    } else {
        [self setScanDir:_scanner.scanResult];
        [self setRootDir: self.scanDir];
        [tabView selectTabViewItemWithIdentifier: @"Filelight"];
    }	//    [m_scanner release];
    _scanner = nil;
}
- (IBAction) cancelScan:  (id)sender	{    if (_scanner) [_scanner cancel];	}
#pragma mark Misc
- (BOOL) application:(NSApplication*)app openFile:(NSString*)filename	{	return [self startScan:filename];	}
- (void) awakeFromNib						{    _scanner = nil;    _scanDir = nil; [self setupToolbar];		}
- (IBAction) open: (id) sender			{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories: YES];
    [openPanel setCanChooseFiles: NO];
    int result = [openPanel runModalForTypes: nil];
    if (result == NSOKButton) {
        NSString *path = [openPanel filenames][0];
        [self startScan: path];
    }
}
- (void) applicationDidFinishLaunching: (NSNotification*)notification	{
    if (![window isVisible]) {
        [self open: self];
    }
}
- (void) setRootDir:(FLDirectory*)dir	{
    [(FLController*)[sizer dataSource] setRootDir: dir];
    [sizer setNeedsDisplay: YES];
    [window setTitle: [dir path]];
}
- (FLDirectory*) rootDir					{    return [(FLController*)[sizer dataSource] rootDir];	}
- (void) parentDir:(id)sender				{

    FLDirectory *parent = [[self rootDir] parent];
    parent ? [self setRootDir: parent] : [self startScan: self.rootDir.path.stringByDeletingLastPathComponent];
}
- (void) refresh:  (id)sender				{  [self startScan: [[self rootDir] path]];	}
@end


//- (FLDirectory*)scanDir {  return m_scanDir;}
//- (void) setScanDir: (FLDirectory*)dir{   [dir retain]; if (m_scanDir) [m_scanDir release];  m_scanDir = dir;	}
