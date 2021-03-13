//
//  ImageItem.m
//  Question Sleuth
//
//  Created by Alexey Kuchmiy on 15.09.12.
//  Copyright (c) 2012 Alexey Kuchmiy. All rights reserved.
//

#import "ImageItem.h"

@implementation ImageItem


-(void)downloadThumb {
    if (_isLoading)
        return;

    _isLoading = YES;
    NSString *host = [_thumbURL pathComponents][1];
    MKNetworkEngine *photoDownloader = [[MKNetworkEngine alloc] initWithHostName:host customHeaderFields:nil];
    MKNetworkOperation *op = [photoDownloader operationWithURLString:_thumbURL];
    [op onCompletion:^(MKNetworkOperation *operation) {
        _isLoading = NO;
        
        UIImage *photo = [UIImage imageWithData:operation.responseData];
        if (photo) {
            NSString *folder = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            NSString *fileName = [NSString stringWithFormat:@"bing-%@",[_thumbURL lastPathComponent]];
            NSString *filePath = [folder stringByAppendingPathComponent:fileName];
            [operation.responseData writeToFile:filePath atomically:YES];
            self.thumbPath = filePath;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"photoDownloaded" object:nil];
        }
        else  {
        }
    }
             onError:^(NSError *error) {
                 NSLog(@"error loading %@",_thumbURL);
                 _isLoading = NO;
                 
             }];
    [photoDownloader enqueueOperation:op];
}
@end
