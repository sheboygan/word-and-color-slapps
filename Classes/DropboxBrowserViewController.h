//
//  DropboxBrowserViewController.h
//  Sequence
//
//  Created by imac on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonVC.h"
#import "GameAppDelegate.h"
#import "BeanLoader.h"
#import "DBCell.h"
#import "MBProgressHUD.h"

@interface DropboxBrowserViewController : CommonVC <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *sectionTitles;
    BeanLoader *loader;
    DBUserClient *restClient;
    DBCell *cell;
    MBProgressHUD *HUD;
    NSString *path;
    IBOutlet UIBarButtonItem *backButton;
    IBOutlet UIBarButtonItem *titleButton;
    int pressedTag;
}
- (IBAction)closePressed:(id)sender;
- (IBAction)logoutPressed:(id)sender;
-(void)beanUploaderDidFailed;
-(void)beanUploaderDidSuccess;
-(void)beanDownloaderDidSuccess;
-(void)beanDownloaderDidFailed;
- (IBAction)backPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) NSMutableArray *remoteContent;
@end
