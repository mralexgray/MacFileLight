/* Copyright (C) 1996 Dave Vasilevsky 
 	This file is licensed under the GNU General Public License, see the file Copying.txt for details. */

#import "FLRadialPainter.h"

#import "FLPolar.h"
#import "NSBezierPath+Segment.h"
#import "FLRadialItem.h"

@implementation NSView (FLRadialPainter)

- (NSPoint) center
{
    NSRect bounds = [self bounds];
    return NSMakePoint(NSMidX(bounds), NSMidY(bounds));
}

- (CGFloat) maxRadius
{
    NSRect bounds = [self bounds];
    NSSize size = bounds.size;
    float minDim = size.width < size.height ? size.width : size.height;
    return minDim / 2.0;
}

@end


@implementation FLRadialPainter

- (id) initWithView: (NSView <FLHasDataSource> *)view;
{
    if (self = [super init]) {
        // Default values
        _maxLevels = 5;
        _minRadiusFraction = 0.1;
        _maxRadiusFraction = 0.9;
        _minPaintAngle = 1.0;
        
        _view = view; // No retain, view should own us
        _colorer = nil;
    }
    return self;
}

#pragma mark Accessors

//- (int) maxLevels
//{
//    return m_maxLevels;
//}
//
//- (void) setMaxLevels: (int)levels
//{
//    NSAssert(levels > 0, @"maxLevels must be positive!");
//    m_maxLevels = levels;
//}

//- (CGFloat) minRadiusFraction
//{
//    return m_minRadiusFraction;
//}
//
//- (void) setMinRadiusFraction: (CGFloat)fraction
//{
//    NSAssert(fraction >= 0.0 && fraction <= 1.0,
//             @"fraction must be between zero and one!");
//    NSAssert(fraction < [self maxRadiusFraction],
//             @"minRadius must be less than maxRadius!");
//    m_minRadiusFraction = fraction;
//}
//
//- (CGFloat) maxRadiusFraction
//{
//    return m_maxRadiusFraction;
//}
//
//- (void) setMaxRadiusFraction: (CGFloat)fraction
//{
//    NSAssert(fraction >= 0.0 && fraction <= 1.0,
//             @"fraction must be between zero and one!");
//    NSAssert(fraction > [self minRadiusFraction],
//             @"minRadius must be less than maxRadius!");
//    m_maxRadiusFraction = fraction;
//}
//
//- (CGFloat) minPaintAngle
//{
//    return m_minPaintAngle;
//}
//
//- (void) setMinPaintAngle: (CGFloat)angle
//{
//    m_minPaintAngle = angle;
//}
//
//- (id) colorer
//{
//    return m_colorer;
//}
//
//- (void) setColorer: (id) c
//{
//    [c retain];
//    if (m_colorer) [m_colorer release];
//    m_colorer = c;
//}

//- (NSView <FLHasDataSource>*)view
//{
//    return m_view;
//}
//
//- (void) setView: (NSView <FLHasDataSource> *)view
//{
//    m_view = view; // No retain, view should own us
//}

#pragma mark Misc

- (FLRadialItem*)root
{
    return [FLRadialItem rootItemWithDataSource: [[self view] dataSource]];
}

- (BOOL) wantItem: (FLRadialItem*)ritem
{
    return [ritem level] < [self maxLevels]
        && [ritem angleSpan] >= [self minPaintAngle];
}

- (CGFloat) radiusFractionPerLevel
{
    float availFraction = [self maxRadiusFraction] - [self minRadiusFraction];
    return availFraction / [self maxLevels];
}

#pragma mark Painting


- (CGFloat) innerRadiusFractionForLevel: (int)level
{
    // TODO: Deal with concept of "visible levels" <= maxLevels
    NSAssert(level <= [self maxLevels], @"Level too high!");    
    return [self minRadiusFraction] + ([self radiusFractionPerLevel] * level);
}

// Default coloring scheme
- (NSColor*)colorForItem: (id) item
                 angleFrac: (CGFloat) angle
                 levelFrac: (CGFloat) level
{
    return [NSColor colorWithCalibratedHue: angle
                                saturation: 0.6 - (level / 4)
                                brightness: 1.0
                                     alpha: 1.0];
}

- (NSColor*)colorForItem: (FLRadialItem *)ritem
{
    float levelFrac = (CGFloat)[ritem level] / ([self maxLevels] - 1);
    float midAngle = [ritem midAngle];
    float angleFrac = midAngle / 360.0;
    
    angleFrac -= floorf(angleFrac);
    NSAssert(angleFrac >= 0 && angleFrac <= 1.0,
             @"Angle fraction must be between zero and one");
    
    id c = _colorer ? _colorer : self;
    return [c colorForItem: [ritem item]
                 angleFrac: angleFrac
                 levelFrac: levelFrac];
}

- (void) drawItem: (FLRadialItem *)ritem
{
    int level = [ritem level];
    float inner = [self innerRadiusFractionForLevel: level];
    float outer = [self innerRadiusFractionForLevel: level + 1];
    NSColor *fill = [self colorForItem: ritem];
    
    NSBezierPath *bp = [NSBezierPath
        circleSegmentWithCenter: [[self view] center]
                     startAngle: [ritem startAngle]
                       endAngle: [ritem endAngle]
                    smallRadius: inner * [[self view] maxRadius]
                      bigRadius: outer * [[self view] maxRadius]];
    
    [fill set];
    [bp fill];
    [[fill shadowWithLevel: 0.4] set];
    [bp stroke];
}



- (void) drawTreeForItem: (FLRadialItem *)ritem
{
    if (![self wantItem: ritem]) {
        return;
    }
    
    if ([ritem level] >= 0 && [ritem weight] > 0) {
        [self drawItem: ritem];
    }
    
    // Draw the children
    NSEnumerator *e = [ritem childEnumerator];
    FLRadialItem *child;
    while (child = [e nextObject]) {
        [self drawTreeForItem: child];
    }
}

- (void)drawRect: (NSRect)rect
{
    // TODO: Choose root item(s) from rect
    [self drawTreeForItem: [self root]];
}

#pragma mark Hit testing

- (id) findChildOf: (FLRadialItem *)ritem
             depth: (int)depth
             angle: (CGFloat)th
{
    NSAssert(depth >= 0, @"Depth must be at least zero");
    NSAssert(th >= [ritem startAngle], @"Not searching the correct tree");
    
    if (![self wantItem: ritem]) {
        return nil;
    }
    
    if (depth == 0) {
        return [ritem item];
    }
    
    NSEnumerator *e = [ritem childEnumerator];
    FLRadialItem *child;
    while (child = [e nextObject]) {
        if ([child endAngle] >= th) {
            return [self findChildOf: child depth: depth - 1 angle: th];
        }
    }
    
    return nil;
}

- (id) itemAt: (NSPoint)point
{
    float r, th;
    [FLPolar coordsForPoint: point center: [[self view] center] intoRadius: &r angle: &th];
    
    float rfrac = r / [[self view] maxRadius];
    if (rfrac < [self minRadiusFraction] || rfrac >= [self maxRadiusFraction]) {
        return nil;
    }
    
    float usedFracs = rfrac - [self minRadiusFraction];
    int depth = floorf(usedFracs / [self radiusFractionPerLevel]) + 1;
    return [self findChildOf: [self root] depth: depth angle: th];
}


@end
