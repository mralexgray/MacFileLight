/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

// Data source: generalization of NSOutlineViewDataSource
// nil object means the root.
@interface NSObject (FLRadialPainterDataSource)
-        (id) child: (NSInteger)index ofItem:(id)item;
- (NSInteger) numberOfChildrenOfItem: 			(id)item;
-   (CGFloat) weightOfItem: 						(id)item;
@end
@interface FLRadialItem : NSObject {
//    id m_dataSource;
//    id m_item;
//    int m_level;
}

- (id) initWithItem: (id)item
         dataSource: (id)dataSource
             weight: (CGFloat)weight
         startAngle: (CGFloat)a1
           endAngle: (CGFloat)a2
              level: (int)level;

@property (assign) id item;
@property NSInteger level;
@property (assign) id dataSource;
@property CGFloat weight, startAngle, endAngle;
@property (readonly) CGFloat midAngle, angleSpan;

- (NSArray*)children;
- (NSEnumerator*)childEnumerator;

+ (FLRadialItem*)rootItemWithDataSource: (id)dataSource;

@end
