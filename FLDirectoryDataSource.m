/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

#import "FLDirectoryDataSource.h"

@implementation FLDirectoryDataSource
-      (id) init												{ return self = [super init] ? _rootDir = nil, self : nil; }
- (FLFile*) realItemFor:(id)item							{	return item ? item : _rootDir;	}
-      (id) child: 		(int)index ofItem:(id)item	{    FLFile *file = [self realItemFor: item];
    return [(FLDirectory*)file children][index];
}
-     (int) numberOfChildrenOfItem: 		(id)item	{    FLFile *file = [self realItemFor: item];
    return [file respondsToSelector:@selector(children)] ? [(FLDirectory*)file children].count : 0;
}
-   (CGFloat) weightOfItem: 						(id)item	{ return (CGFloat)[(FLFile *)[self realItemFor:item] size];	}
@end
