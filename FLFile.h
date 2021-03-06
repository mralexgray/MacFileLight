/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

typedef unsigned long long FLFile_size;
typedef NS_ENUM ( NSUInteger, FLFileSizeType ){
    SizeTypeSIBinary    = 0x0,  // 1 KiB = 1024 bytes
    SizeTypeSIDecimal   = 0x1,  // 1 KB = 1000 bytes
    SizeTypeOldBinary   = 0x2,  // 1 KB = 1024 bytes
    SizeTypeBaseMask    = 0xF,
    SizeTypeShort       = 0x00,
    SizeTypeLong        = 0x10,
    SizeTypeLengthMask  = 0xF0
};

@interface 							FLFile : NSObject
@property (readonly) 	     NSImage * icon;
@property (readonly)        NSString * displaySize;
@property     (copy)			 NSString * path;
@property   (assign)	    FLFile_size  	size;

- (id) initWithPath: (NSString*)path
					size: (FLFile_size)size;

+ (NSString*) humanReadableSize: (FLFile_size)size
									type: (FLFileSizeType)type
								sigFigs: (size_t)figs;
@end

@interface 					 FLDirectory : FLFile
@property (strong) 		     NSArray * children;
@property (strong)       FLDirectory * parent;

- (id) initWithPath: (NSString*)path parent: (FLDirectory*)parent;
- (void)   addChild: (FLFile*)child;
@end
