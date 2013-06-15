/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

#import "FLRadialItem.h"
#import "FLRadialPainter.h"

@implementation FLRadialItem
@synthesize item = m_item, dataSource = m_dataSource, weight = m_weight, startAngle = m_startAngle, endAngle = m_endAngle, level = m_level;

- (id) initWithItem: (id)item
         dataSource: (id)dataSource
             weight: (CGFloat)weight
         startAngle: (CGFloat)a1
           endAngle: (CGFloat)a2
              level: (int)level	{

	return self = super.init ? m_item 		= item,		m_dataSource 	= dataSource,
										m_weight 	= weight,	m_startAngle 	= a1,
										m_endAngle 	= a2,		 	m_level 			= level, self : nil;
}
- (CGFloat) midAngle		{ return (self.startAngle + self.endAngle) / 2.0;	}
- (CGFloat) angleSpan	{ return self.endAngle - self.startAngle;				}
- (NSArray*)children		{ if ([self weight] == 0.0)  return @[];
    
    __block CGFloat curAngle = self.startAngle;
    			CGFloat anglePerWeight 	= self.angleSpan / self.weight;
    id item 					= self.item;
    int m = [m_dataSource numberOfChildrenOfItem: item];
    __block NSMutableArray *children = [NSMutableArray arrayWithCapacity: m];
    
    int i;
    for (i = 0; i < m; ++i) {
        id sub = [m_dataSource child: i ofItem: item];
        float subw = [m_dataSource weightOfItem: sub];
        float subAngle = anglePerWeight * subw;
        float nextAngle = curAngle + subAngle;
        
        id child = [[FLRadialItem alloc] initWithItem: sub
                                           dataSource: m_dataSource
                                               weight: subw
                                           startAngle: curAngle
                                             endAngle: nextAngle
                                                level: [self level] + 1];
        [children addObject: child];
        curAngle = nextAngle;
    }
    return children;
}

- (NSEnumerator *)childEnumerator
{
    return [[self children] objectEnumerator];
}

+ (FLRadialItem*)rootItemWithDataSource: (id)dataSource
{
    return [FLRadialItem.alloc initWithItem: nil
                              	dataSource: dataSource
                                     weight: [dataSource weightOfItem: nil]
											startAngle: 0
											  endAngle: 360
												  level: -1];
}


@end
