/* Copyright (C) 1996 Dave Vasilevsky
 * This file is licensed under the GNU General Public License,
 * see the file Copying.txt for details. */

#import "FLFile.h"

// As defined in stat(2)
#define BLOCK_SIZE 512

@implementation FLFile
- (NSImage*) icon { return [NSWorkspace.sharedWorkspace iconForFile:_path]; }
- (NSString*)displaySize															{
	return [FLFile humanReadableSize: [self size]
										 type: SizeTypeOldBinary | SizeTypeShort
									 sigFigs: 3];
}
- (id) initWithPath: (NSString*)path size: (FLFile_size) size			{
    return self = [super init] ? _path = path, _size = size, self : nil;
}
+ (NSString*)humanReadableSize: (FLFile_size) size
                          type: (FLFileSizeType) type
                       sigFigs: (size_t) figs								{
	unsigned idx, base, digits, deci;
	double fsize;
	FLFileSizeType length, baseType;
	NSString *pref, *suf;

	NSArray *prefixes = @[@"", @"kilo", @"mega",
								 @"giga", @"peta", @"exa", @"zetta", @"yotta"];

	baseType = type & SizeTypeBaseMask;
	base = (baseType == SizeTypeSIDecimal) ? 1000 : 1024;

		// Find proper prefix
	fsize = size;
	idx = 0;
	while (fsize >= base && idx < [prefixes count]) {
		++idx;
		fsize /= base;
	}
	pref = prefixes[idx];

		// Precision
	digits = 1 + (unsigned)log10(fsize);
	deci = (digits > figs || idx == 0) ? 0 : figs - digits;
	fsize = pow(10.0, 0.0 - deci) * rint(fsize * pow(10.0, 0.0 + deci));

		// Unit suffix
	length = type & SizeTypeLengthMask;
	suf = (length == SizeTypeLong) ? @"byte" : @"B";
	if (length == SizeTypeLong && fsize != 1.0) { // plural
		suf = [suf stringByAppendingString: @"s"];
	}

		// Unit prefix
	if (idx > 0) {
		if (length == SizeTypeShort) {
			pref = [[pref substringToIndex: 1] uppercaseString];
			if (baseType == SizeTypeSIBinary) {
				pref = [pref stringByAppendingString: @"i"];
			}
		} else if (baseType == SizeTypeSIBinary) {
			pref = [[pref substringToIndex: 2] stringByAppendingString: @"bi"];
		}
	}

	return [NSString stringWithFormat: @"%.*f %@%@", deci, fsize, pref, suf];
}
@end
@implementation FLDirectory
- (id) initWithPath: (NSString*) path parent: (FLDirectory*)parent	{
    return self = [super initWithPath: path size: 0]
					 ? _children = NSMutableArray.new, _parent = parent, self : nil;
}
- (void) addChild:     (FLFile*) child											{	[[self mutableArrayValueForKey:@"children"]addObject:child];
													self.size += [child size];
}

@end
