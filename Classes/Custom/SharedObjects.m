//
//  SharedObjects.m
//  Pentatonix
//
//  Created by Alexey Kuchmiy on 27.01.13.
//  Copyright (c) 2013 Alexey. All rights reserved.
//


#import "SharedObjects.h"

@implementation SharedObjects

+ (SharedObjects*) objects;
{
    static SharedObjects *objects;
    if (nil != objects) {
        return objects;
    }
    
    static dispatch_once_t pred;        
    dispatch_once(&pred, ^{
        objects = [[SharedObjects alloc] init];
    });
    
    return objects;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isPro = YES;

        if ([[[NSBundle mainBundle] bundleIdentifier] hasSuffix: @"lite"])
        {
            self.isPro = NO;
        }

        if ([[[NSBundle mainBundle] bundleIdentifier] hasSuffix: @".color"])
        {
            self.isColorSlapps = YES;
        }

    }
    
    return self;
}
@end
