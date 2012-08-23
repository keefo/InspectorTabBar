//
//  SMBar.m
//  InspectorTabBar
//
//  Created by Stephan Michels on 12.02.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SMBar.h"

@implementation SMBar

#pragma mark - Initialization / Deallocation

// using app and window notifications to change gradient for inactive windows, see
// http://code.google.com/p/tlanimatingoutlineview/source/browse/trunk/Classes/TLGradientView.m
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(windowDidChange:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
        [center addObserver:self selector:@selector(windowDidChange:) name:NSApplicationDidResignActiveNotification object:NSApp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(windowDidChange:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
        [center addObserver:self selector:@selector(windowDidChange:) name:NSApplicationDidResignActiveNotification object:NSApp];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    NSWindow *oldWindow = [self window];
    if (oldWindow) {
        [center removeObserver:self name:NSWindowDidResignKeyNotification object:oldWindow];
        [center removeObserver:self name:NSWindowDidBecomeKeyNotification object:oldWindow];
    }
    
    if (newWindow) {
        [center addObserver:self selector:@selector(windowDidChange:) name:NSWindowDidResignKeyNotification object:newWindow];
        [center addObserver:self selector:@selector(windowDidChange:) name:NSWindowDidBecomeKeyNotification object:newWindow];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    if ([[self window] isKeyWindow]) {
        static NSGradient *gradient = nil;
        static NSColor *borderColor = nil;
        if (!gradient) {
            NSColor *color1 = [NSColor colorWithCalibratedRed:0.851 green:0.851 blue:0.851 alpha:1.];
            NSColor *color2 = [NSColor colorWithCalibratedRed:0.700 green:0.700 blue:0.700 alpha:1.];
            gradient = [[NSGradient alloc] initWithStartingColor:color1
                                                     endingColor:color2];
            borderColor = [NSColor colorWithCalibratedRed:0.416 green:0.416 blue:0.416 alpha:1];
        }
        
        // Draw bar gradient
        [gradient drawInRect:self.bounds angle:90.0];
        
        // add noise
        [self drawNoisePattern];
        
        // Draw drak gray bottom border
        [borderColor setStroke];
        [NSBezierPath setDefaultLineWidth:0.0f];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds) + 0.5f, NSMaxY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds) - 0.5f, NSMaxY(self.bounds) - 0.5f)];
    } else {
        static NSGradient *gradient = nil;
        static NSColor *borderColor = nil;
        if (!gradient) {
            NSColor *color1 = [NSColor colorWithCalibratedRed:0.965 green:0.965 blue:0.965 alpha:1];
            NSColor *color2 = [NSColor colorWithCalibratedRed:0.851 green:0.851 blue:0.851 alpha:1];
            gradient = [[NSGradient alloc] initWithStartingColor:color1
                                                     endingColor:color2];
            borderColor = [NSColor colorWithCalibratedRed:0.651 green:0.651 blue:0.651 alpha:1];
        }
        
        // Draw bar gradient
        [gradient drawInRect:self.bounds angle:90.0];
        
        // add noise
        [self drawNoisePattern];
        
        // Draw drak gray bottom border
        [borderColor setStroke];
        [NSBezierPath setDefaultLineWidth:0.0f];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds) + 0.5f, NSMaxY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds) - 0.5f, NSMaxY(self.bounds) - 0.5f)];
    }
}

// add noise pattern, see http://stackoverflow.com/questions/8766239
- (void)drawNoisePattern {
    static CGImageRef noisePattern = nil;
    if (noisePattern == nil) {
        noisePattern = SMNoiseImageCreate(128, 128, 0.015);
    }
    
    [NSGraphicsContext saveGraphicsState];
    
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositePlusLighter];
    CGRect noisePatternRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(noisePattern), CGImageGetHeight(noisePattern));
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawTiledImage(context, noisePatternRect, noisePattern);
    
    [NSGraphicsContext restoreGraphicsState];
}

static CGImageRef SMNoiseImageCreate(NSUInteger width, NSUInteger height, CGFloat factor) {
    NSUInteger size = width * height;
    char *rgba = (char *)malloc(size); srand(124);
    for(NSUInteger i = 0; i < size; i++) {
        rgba[i] = rand() % 256 * factor;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba, width, height, 8, width, colorSpace, kCGImageAlphaNone);
    CFRelease(colorSpace);
    free(rgba);
    
    CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    CFRelease(bitmapContext);
    
    return image;
}

- (BOOL)isFlipped {
    return YES;
}

#pragma mark - Notifications

- (void)windowDidChange:(NSNotification *)notification {
    [self setNeedsDisplay:YES];
}

@end
