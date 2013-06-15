/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

// Utility functions
@interface NSView (FLRadialPainter)
- (NSPoint) center;
- (CGFloat) maxRadius;
@end

// Colorer
@interface NSObject (FLColorer)
- (NSColor*)colorForItem: (id) item
                 angleFrac: (CGFloat) angle
                 levelFrac: (CGFloat) level;
@end

@protocol FLHasDataSource
- (id) dataSource;
@end

@interface FLRadialPainter : NSObject
{
//    int m_maxLevels;
//    float m_minRadiusFraction, m_maxRadiusFraction;
//    float m_minPaintAngle;
//    
//    NSView <FLHasDataSource> *m_view;
//    id m_colorer;
}

// Accessors
@property int maxLevels;

//- (void) setMaxLevels: (int)levels;
@property float minRadiusFraction, maxRadiusFraction, minPaintAngle;
//- (void) setMinRadiusFraction: (CGFloat)fraction;
//- (CGFloat) maxRadiusFraction;
//- (void) setMaxRadiusFraction: (CGFloat)fraction;
//- (CGFloat) minPaintAngle;
//- (void) setMinPaintAngle: (CGFloat)angle;

@property (strong) id colorer;
//- (id) colorer;
//- (void) setColorer: (id) c;

@property (weak)NSView <FLHasDataSource> * view;
//- (void) setView: (NSView <FLHasDataSource> *)view;

- (id) initWithView: (NSView <FLHasDataSource> *)view;

- (void)drawRect: (NSRect)rect;
- (id)itemAt: (NSPoint)point;

@end
