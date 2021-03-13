//
//  CategoryBean.m
//  Game
//
//  Created by sandra on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CategoryBean.h"


@implementation CategoryBean

@synthesize record_ID, name, image, audio, category, bt, b_Sel;


-(NSString*)name {
    return NSLocalizedString(name, @"");
}

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    NSData *imageData = [NSData dataWithContentsOfFile:[self imageFilePath]];
    NSData *audioData = [NSData dataWithContentsOfFile:[self audioFilePath]];
    
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:imageData forKey:@"imageData"];
    [encoder encodeObject:audioData forKey:@"audioData"];
    
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        name = [decoder decodeObjectForKey:@"name"];
        
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateFormat:@"MMddyyyyHHmmss"];
        
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef randomString = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        
		NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
        audio = [NSString stringWithFormat:@"import_%@_%@", randomString, currentTime];
		image = [NSString stringWithFormat:@"import_%@_%@", randomString, currentTime];
        
        
        NSData *imageData = [decoder decodeObjectForKey:@"imageData"]; 
        NSData *audioData = [decoder decodeObjectForKey:@"audioData"]; 
        if (imageData.length>0) {
            [imageData writeToFile:[self imageFilePath] atomically:YES];
        }
        if (audioData.length>0) {
            [audioData writeToFile:[self audioFilePath] atomically:YES];
        }
    }
    return self;
}

-(NSString*)audioFilePath {
    return [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, audio];
}


-(NSString*)imageFilePath {
    return [NSString stringWithFormat:@"%@/%@.png", DOCUMENTS_FOLDER, image];
}

@end
