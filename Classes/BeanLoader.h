//
//  BeanUploader.h
//  Sequence
//
//  Created by imac on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameAppDelegate.h"
#import "CateBean.h"
#import "MBProgressHUD.h"

@class DropboxBrowserViewController;
@interface BeanLoader : NSObject
{
    NSMutableArray *content;
    DBUserClient *restClient;
    NSString *tmpFilePath;
    MBProgressHUD *HUD;
    
}
@property (nonatomic,weak) DropboxBrowserViewController *delegate;
@property (nonatomic,strong) CateBean *currentBean;


-(void)downloadBeanFromPath:(NSString*)path;
-(void)uploadBeanAtPath:(NSString*)path;
@end
