//
//  ImageItem.h
//  Question Sleuth
//
//  Created by Alexey Kuchmiy on 15.09.12.
//  Copyright (c) 2012 Alexey Kuchmiy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageItem : NSObject
@property (nonatomic,strong) NSString *thumbURL;
@property (nonatomic,strong) NSString *sourceURL;
@property (nonatomic,strong) NSString *thumbPath;
@property (nonatomic,strong) NSString *sourcePath;
@property (nonatomic,assign) BOOL isLoading;
-(void)downloadThumb;
@end
