//
//  ImageResultCell.m
//  Question Sleuth
//
//  Created by Alexey Kuchmiy on 15.09.12.
//  Copyright (c) 2012 Alexey Kuchmiy. All rights reserved.
//

#import "ImageResultCell.h"

@implementation ImageResultCell
@synthesize b1;
@synthesize a1;
@synthesize i1;
@synthesize c1;
@synthesize c2;
@synthesize i2;
@synthesize a2;
@synthesize b2;
@synthesize c3;
@synthesize i3;
@synthesize a3;
@synthesize b3;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
