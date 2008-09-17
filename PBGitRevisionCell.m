//
//  PBGitRevisionCell.m
//  GitX
//
//  Created by Pieter de Bie on 17-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBGitRevisionCell.h"
#import "PBGitRef.h"

@implementation NSBezierPath (RoundedRectangle)
+ (NSBezierPath *)bezierPathWithRoundedRect: (NSRect) aRect cornerRadius: (double) cRadius
{
	double left = aRect.origin.x, bottom = aRect.origin.y, width = aRect.size.width, height = aRect.size.height;

	//now, crop the radius so we don't get weird effects
	double lesserDim = width < height ? width : height;
	if ( cRadius > lesserDim / 2 )
	{
		cRadius = lesserDim / 2;
	}

	//these points describe the rectangle as start and stop points of the
	//arcs making up its corners --points c, e, & g are implicit endpoints of arcs
	//and are unnecessary
	NSPoint a = NSMakePoint( 0, cRadius ), b = NSMakePoint( 0, height - cRadius ),
		d = NSMakePoint( width - cRadius, height ), f = NSMakePoint( width, cRadius ),
		h = NSMakePoint( cRadius, 0 );

	//these points describe the center points of the corner arcs
	NSPoint cA = NSMakePoint( cRadius, height - cRadius ),
		cB = NSMakePoint( width - cRadius, height - cRadius ),
		cC = NSMakePoint( width - cRadius, cRadius ),
		cD = NSMakePoint( cRadius, cRadius );

	//start
	NSBezierPath *bp = [NSBezierPath bezierPath];
	[bp moveToPoint: a ];
	[bp lineToPoint: b ];
	[bp appendBezierPathWithArcWithCenter: cA radius: cRadius startAngle:180 endAngle:90 clockwise: YES];
	[bp lineToPoint: d ];
	[bp appendBezierPathWithArcWithCenter: cB radius: cRadius startAngle:90 endAngle:0 clockwise: YES];
	[bp lineToPoint: f ];
	[bp appendBezierPathWithArcWithCenter: cC radius: cRadius startAngle:0 endAngle:270 clockwise: YES];
	[bp lineToPoint: h ];
	[bp appendBezierPathWithArcWithCenter: cD radius: cRadius startAngle:270 endAngle:180 clockwise: YES];	
	[bp closePath];

	//Transform path to rectangle's origin
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy: left yBy: bottom];
	[bp transformUsingAffineTransform: transform];

	return bp; //it's already been autoreleased
}
@end

@implementation PBGitRevisionCell


- (id) initWithCoder: (id) coder
{
	self = [super initWithCoder:coder];
	textCell = [[NSTextFieldCell alloc] initWithCoder:coder];
	return self;
}

- (NSArray*) colors
{
	return 	[NSArray arrayWithObjects:
				[NSColor colorWithCalibratedRed: 0X4e/256.0 green:0X9A/256.0 blue: 0X06/256.0 alpha: 1.0],
				[NSColor colorWithCalibratedRed: 0X20/256.0 green:0X4A/256.0 blue: 0X87/256.0 alpha: 1.0],
				[NSColor colorWithCalibratedRed: 0XC4/256.0 green:0XA0/256.0 blue: 0 alpha: 1.0],
				[NSColor colorWithCalibratedRed: 0X5C/256.0 green:0X35/256.0 blue: 0X66/256.0 alpha: 1.0],
				[NSColor colorWithCalibratedRed: 0XA4/256.0 green:0X00/256.0 blue: 0X00/256.0 alpha: 1.0],
				[NSColor colorWithCalibratedRed: 0XCE/256.0 green:0X5C/256.0 blue: 0 alpha: 1.0],
				nil];
}

- (void) drawLineFromColumn: (int) from toColumn: (int) to inRect: (NSRect) r offset: (int) offset color: (int) c
{

	int columnWidth = 10;
	NSPoint origin = r.origin;
	
	NSPoint source = NSMakePoint(origin.x + columnWidth* from, origin.y + offset);
	NSPoint center = NSMakePoint( origin.x + columnWidth * to, origin.y + r.size.height * 0.5);

	// Just use red for now.
	NSArray* colors = [self colors];
	[[colors objectAtIndex: c % [colors count]] set];
	
	NSBezierPath * path = [NSBezierPath bezierPath];
	[path setLineWidth:2];
	
	[path moveToPoint: source];
	[path lineToPoint: center];
	[path stroke];
	
}

- (void) drawCircleInRect: (NSRect) r
{

	int c = cellInfo.position;
	int columnWidth = 10;
	NSPoint origin = r.origin;
	NSPoint columnOrigin = { origin.x + columnWidth * c, origin.y};

	NSRect oval = { columnOrigin.x - 5, columnOrigin.y + r.size.height * 0.5 - 5, 10, 10};

	
	NSBezierPath * path = [NSBezierPath bezierPath];
	path = [NSBezierPath bezierPathWithOvalInRect:oval];

	[[NSColor blackColor] set];
	[path fill];
	
	NSRect smallOval = { columnOrigin.x - 3, columnOrigin.y + r.size.height * 0.5 - 3, 6, 6};
	[[NSColor whiteColor] set];
	path = [NSBezierPath bezierPathWithOvalInRect:smallOval];
	[path fill];	
}

- (void) drawTriangleInRect: (NSRect) r sign: (char) sign
{
	int c = cellInfo.position;
	int columnHeight = 10;
	int columnWidth = 8;

	NSPoint top;
	if (sign == '<')
		top.x = round(r.origin.x) + 10 * c + 4;
	else {
		top.x = round(r.origin.x) + 10 * c - 4;
		columnWidth *= -1;
	}
	top.y = r.origin.y + (r.size.height - columnHeight) / 2;

	NSBezierPath * path = [NSBezierPath bezierPath];
	// Start at top
	[path moveToPoint: NSMakePoint(top.x, top.y)];
	// Go down
	[path lineToPoint: NSMakePoint(top.x, top.y + columnHeight)];
	// Go left top
	[path lineToPoint: NSMakePoint(top.x - columnWidth, top.y + columnHeight / 2)];
	// Go to top again
	[path closePath];

	[[NSColor whiteColor] set];
	[path fill];
	[[NSColor blackColor] set];
	[path setLineWidth: 2];
	[path stroke];
}

- (NSMutableDictionary*) attributesForRefLabelSelected: (BOOL) selected
{
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
	NSMutableParagraphStyle* style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	
	[style setAlignment:NSCenterTextAlignment];
	[attributes setObject:style forKey:NSParagraphStyleAttributeName];
	[attributes setObject:[NSFont fontWithName:@"Helvetica"	size:9] forKey:NSFontAttributeName];

	//if (selected)
	//	[attributes setObject:[NSColor alternateSelectedControlTextColor] forKey:NSForegroundColorAttributeName];

	return attributes;
}

- (NSColor*) colorForRef: (PBGitRef*) ref
{
	NSString* type = [ref type];
	if ([type isEqualToString:@"head"])
		return [NSColor colorWithCalibratedRed: 0Xaa/256.0 green:0Xf2/256.0 blue: 0X54/256.0 alpha: 1.0];
	else if ([type isEqualToString:@"remote"])
		return [NSColor colorWithCalibratedRed: 0xb2/256.0 green:0Xdf/256.0 blue: 0Xff/256.0 alpha: 1.0];
	else if ([type isEqualToString:@"tag"])
		return [NSColor colorWithCalibratedRed: 0Xfc/256.0 green:0Xed/256.0 blue: 0X4f/256.0 alpha: 1.0];
	
	return [NSColor yellowColor];
}

- (void) drawRefsInRect: (NSRect*) rect
{
	static const float ref_padding = 10.0f;
	static const float ref_spacing = 2.0f;

	NSArray* refs = [self.objectValue refs];
	NSRect refRect = (NSRect){rect->origin, rect->size};

	[[NSColor blackColor] setStroke];

	int index;
	for (index = 0; index < [refs count]; ++index) {
		PBGitRef* ref    = [refs objectAtIndex:index];

		NSMutableDictionary* attributes = [self attributesForRefLabelSelected:[self isHighlighted]];
		NSSize refSize = [[ref shortName] sizeWithAttributes:attributes];
		
		refRect.size.width = refSize.width + ref_padding;
		refRect.size.height = refSize.height;
		refRect.origin.y = rect->origin.y + (rect->size.height - refRect.size.height) / 2; 
		
		// Round rects to 0.5 pixels in order to draw only a single pixel
		refRect.origin.x = round(refRect.origin.x) - 0.5;
		refRect.origin.y = round(refRect.origin.y) - 0.5;

		NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:refRect cornerRadius: 2.0];
		[[self colorForRef: ref] set];
		[border fill];

		[[ref shortName] drawInRect:refRect withAttributes:attributes];
		[border stroke];

		refRect.origin.x += (int)refRect.size.width + ref_spacing;
	}

	rect->size.width -= refRect.origin.x - rect->origin.x;
	rect->origin.x    = refRect.origin.x;
}

- (void) drawWithFrame: (NSRect) rect inView:(NSView *)view
{
	cellInfo = [self.objectValue lineInfo];
	
	if (cellInfo) {
		float pathWidth = 10 + 10 * cellInfo.numColumns;

		NSRect ownRect;
		NSDivideRect(rect, &ownRect, &rect, pathWidth, NSMinXEdge);

		for (PBGitGraphLine* line in cellInfo.lines) {
			if (line.upper == 0)
				[self drawLineFromColumn: line.from toColumn: line.to inRect:ownRect offset: ownRect.size.height color: line.colorIndex];
			else
				[self drawLineFromColumn: line.from toColumn: line.to inRect:ownRect offset: 0 color:line.colorIndex];
		}

		if (cellInfo.sign == '<' || cellInfo.sign == '>')
			[self drawTriangleInRect: ownRect sign: cellInfo.sign];
		else
			[self drawCircleInRect: ownRect];
	}

	if ([self.objectValue refs])
		[self drawRefsInRect:&rect];

	// Still use this superclass because of hilighting differences
	//_contents = [self.objectValue subject];
	//[super drawWithFrame:rect inView:view];
	[textCell setObjectValue: [self.objectValue subject]];
	[textCell setHighlighted: [self isHighlighted]];
	[textCell drawWithFrame:rect inView: view];
}

- (void) setObjectValue: (PBGitCommit*)object {
	[super setObjectValue:[NSValue valueWithNonretainedObject:object]];
}

- (PBGitCommit*) objectValue {
    return [[super objectValue] nonretainedObjectValue];
}

@end
