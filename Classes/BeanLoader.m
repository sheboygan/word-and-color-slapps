//
//  BeanUploader.m
//  Sequence
//
//  Created by imac on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BeanLoader.h"
#import "RemoteSequenceBean.h"
#import "DropboxBrowserViewController.h"
#import "CategoryBean.h"
#import "UIApplication+Navigation.h"

@implementation BeanLoader
@synthesize currentBean;
@synthesize delegate;


-(id)init {
    self = [super init];
    restClient = [DBClientsManager authorizedClient];
    content = [[NSMutableArray alloc] init];
    tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"sequence.tmp"];

    return self;
}


-(void)downloadBeanFromPath:(NSString*)path {
    HUD = [[MBProgressHUD alloc] initWithView:delegate.view];
    [delegate.view addSubview:HUD];	
    HUD.dimBackground = YES;
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Downloading...";
    [HUD show:YES];
    NSURL* url = [NSURL fileURLWithPath: tmpFilePath];
    [[[restClient.filesRoutes downloadUrl:path overwrite:true destination: url] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSURL * _Nonnull destination) {
        [HUD hide:YES];
        if (networkError) {
            [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: networkError.userMessage];
            [(DropboxBrowserViewController*)delegate beanDownloaderDidFailed];
            return;
        }
        
        if (result) {
            
            NSString *fileName = [result.name stringByDeletingPathExtension];

            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
            RemoteSequenceBean *newItem = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (![fileName isEqualToString:newItem.name]) {
                [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: @"Incorrect file format"];
                return;
            }
            
            GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSMutableArray *toRemove = [NSMutableArray array];
            for (CateBean *bean in app.localFiles ) {
                if ([bean.name isEqualToString:newItem.name] && toRemove.count == 0) {
                    [toRemove addObject:bean];
                }
            }
            if (toRemove.count>0) {
                CateBean *s = [toRemove lastObject];
                [s deleteFromDatabase];
                [app.localFiles removeObject:s];
            }
            [newItem insertIntoDatabase];
            newItem.lastModifiedDate = result.clientModified;
            [(DropboxBrowserViewController*)delegate beanDownloaderDidSuccess];
        } else {
            NSString *errorMessage = @"You must be connected to the Internet to access Dropbox.";
            [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: errorMessage];
            [(DropboxBrowserViewController*)delegate beanDownloaderDidFailed];
        }
    }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        float percentDone = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        HUD.progress = percentDone;
    }];
}


-(void)uploadBeanAtPath:(NSString*)path {
    [self getImagesfromDB];
    RemoteSequenceBean *remoteItem = [[RemoteSequenceBean alloc]init];
    remoteItem.name = currentBean.name;
    remoteItem.content = content;
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:remoteItem];
    [fileData writeToFile:tmpFilePath atomically:YES];
    
    HUD = [[MBProgressHUD alloc] initWithView:delegate.view];
    [delegate.view addSubview:HUD];	
    HUD.dimBackground = YES;
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Uploading...";
    [HUD show:YES];
    
    NSString *remoteFilename = [remoteItem.name stringByAppendingFormat:@".wsl"];
    
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    [restClient.filesRoutes deleteV2: [NSString stringWithFormat:@"%@/%@",path, remoteFilename]];
    
    [[[restClient.filesRoutes uploadUrl: [NSString stringWithFormat:@"%@/%@",path, remoteFilename]
                                   mode:mode
                             autorename:@(YES)
                         clientModified:currentBean.lastModifiedDate
                                   mute:@(NO)
                         propertyGroups:NULL
                               inputUrl:tmpFilePath] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        [HUD hide:YES];
        if (networkError) {
            [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: networkError.userMessage];
            [(DropboxBrowserViewController*)delegate beanUploaderDidFailed];
            return;
        }

        if (result) {
            currentBean.lastModifiedDate = result.clientModified;
            [(DropboxBrowserViewController*)delegate beanUploaderDidSuccess];
        } else {
            NSString *errorMessage = @"You must be connected to the Internet to access Dropbox.";
            [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: errorMessage];
            [(DropboxBrowserViewController*)delegate beanUploaderDidFailed];
        }

    }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        float percentDone = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        HUD.progress = percentDone;
    }];
}


-(void)getImagesfromDB
{

    [content removeAllObjects];
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select id, name,image, audio from image WHERE category=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, (int)currentBean.cateID);
			while(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
				CategoryBean *cBean = [[CategoryBean alloc] init];
                cBean.record_ID = sqlite3_column_int(statements, 0);
				if (sqlite3_column_text(statements, 1)) {
					cBean.name = @((char *)sqlite3_column_text(statements, 1));
				}else {
					cBean.name = @"";
				}
				if (sqlite3_column_text(statements, 2)) {
					cBean.image = @((char *)sqlite3_column_text(statements, 2));
				}else {
					cBean.image = @"";
				}
				if (sqlite3_column_text(statements, 3)) {
					cBean.audio = @((char *)sqlite3_column_text(statements, 3));
				}else {
					cBean.audio = @""; 
				}
                
                [content addObject:cBean];		
			}
			sqlite3_finalize(statements);
		}	
	}	
}

@end
