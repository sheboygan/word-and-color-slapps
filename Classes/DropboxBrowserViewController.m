//
//  DropboxBrowserViewController.m
//  Sequence
//
//  Created by imac on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DropboxBrowserViewController.h"
#import "CateBean.h"
#import "ViewFolderVC.h"
#import "UIApplication+Navigation.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface DropboxBrowserViewController ()

@end

@implementation DropboxBrowserViewController
@synthesize tableView;
@synthesize content;
@synthesize remoteContent;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    content = appDelegate.localFiles;
    remoteContent = [[NSMutableArray alloc] init];
    [tableView setBackgroundView:nil];
    [tableView setBackgroundView:[[UIView alloc] init]];
    loader = [[BeanLoader alloc] init];
    loader.delegate = self;
    
    sectionTitles = [[NSArray alloc] initWithObjects:@"Remote Sequences",@"Local Sequences", nil];
    restClient = [DBClientsManager authorizedClient];
    path = @"";
    backButton.enabled = NO;
    titleButton.title = @"Dropbox";
    [self requestRemoteContent];
}

- (void)viewDidUnload
{
    [self setTableView:nil];

    backButton = nil;
    titleButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)closePressed:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];

    id lastVC = [appDelegate.navController.viewControllers lastObject];
    if ([lastVC respondsToSelector:@selector(refreshContent)]) {
        [(ViewFolderVC*)lastVC refreshContent];
    }
    
}
- (IBAction)logoutPressed:(id)sender {
    [DBClientsManager unlinkAndResetClients];
    [self closePressed:nil];
}

- (IBAction)backPressed:(id)sender {
    path = [path stringByDeletingLastPathComponent];
    if ([path isEqualToString: @"/"]) {
        path = @"";
    }
    [self requestRemoteContent];
}

#pragma mark Networking
-(void)requestRemoteContent {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];	
    HUD.dimBackground = YES;
    HUD.labelText = @"Loading...";
    [HUD show:YES];

    [[restClient.filesRoutes listFolder: path]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         [HUD hide:YES];
         if (networkError) {
             [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message:networkError.userMessage];
             return;
         }
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             [remoteContent removeAllObjects];
             
             for (DBFILESMetadata *entry in entries) {
                 if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
                     DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)entry;
                     if ([[[fileMetadata.name pathExtension] lowercaseString] isEqualToString: @"wsl"]) {
                         [remoteContent addObject: entry];
                     }
                 } else if ([entry isKindOfClass:[DBFILESFolderMetadata class]]) {
                     [remoteContent addObject: entry];
                 }
             }

             [UIView animateWithDuration:0.3 animations:^{
                 if (path.length<=1) {
                     backButton.enabled = NO;
                     titleButton.title = @"Dropbox";
                 }
                 else {
                     backButton.enabled = YES;
                     titleButton.title = path;
                     
                 }
             }];
             [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
             [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
             
             if ([response.hasMore boolValue]) {
                 NSLog(@"Folder is large enough where we need to call `listFolderContinue:`");
             }
         } else {
             [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: @"Failed loading"];
         }
     }];
}

#pragma mark TableViewDelegate
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return sectionTitles[section];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return remoteContent.count;
    return [content count];
}

-(BOOL)isLocalItemSynced:(CateBean*)bean {
    for (DBFILESMetadata *entry in remoteContent) {
        if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
            DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)entry;
            if ([[fileMetadata.name stringByDeletingPathExtension] isEqualToString: bean.name] && bean.lastModifiedDate == fileMetadata.clientModified) {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)isRemoteItemSynced:(DBFILESFileMetadata*)fileMetadata {
    for (CateBean *bean in content) {
        if ([[fileMetadata.name stringByDeletingPathExtension] isEqualToString: bean.name] && bean.lastModifiedDate == fileMetadata.clientModified) {
            return YES;
        }
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *MyIdentifier = @"cell";
    cell = (DBCell*)[atableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
	if (cell == nil) 
	{
        NSArray *cellsArray = [[NSBundle mainBundle] loadNibNamed:@"DBCell" owner:self options:nil];		
		cell = [cellsArray lastObject];
        [cell.actionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterMediumStyle];
    
    NSInteger sec = (indexPath.section+1)*1000;
    cell.actionButton.tag = indexPath.row + sec;
    cell.statusImage.alpha = 0;
    cell.actionButton.alpha = 0;

    if (indexPath.section == 0) {
        cell.statusImage.image = [UIImage imageNamed:@"dCheckmark.png"];
        [cell.actionButton setImage:[UIImage imageNamed:@"butDownload.png"] forState:UIControlStateNormal];

        DBFILESMetadata *item = remoteContent[indexPath.row];
        cell.name.text = [item.name stringByDeletingPathExtension];

        if ([item isKindOfClass:[DBFILESFileMetadata class]]) {
            DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)item;
            if ([self isRemoteItemSynced:fileMetadata]) {
                cell.statusImage.alpha = 1;
            } else {
                cell.actionButton.alpha = 1;
            }
            cell.modifiedDate.text = [df stringFromDate: fileMetadata.clientModified];
        }

        if ([item isKindOfClass:[DBFILESFolderMetadata class]]) {
            [cell.actionButton setImage:[UIImage imageNamed:@"butFolder.png"] forState:UIControlStateNormal];
            cell.modifiedDate.text = @"";
            cell.actionButton.alpha = 1;
        }
    }
    
    if (indexPath.section == 1) {
       CateBean *seq = content[indexPath.row];
        cell.name.text = seq.name;
        cell.statusImage.image = [UIImage imageNamed:@"dCheckmark.png"];
        [cell.actionButton setImage:[UIImage imageNamed:@"butUpload.png"] forState:UIControlStateNormal];
        cell.modifiedDate.text = [df stringFromDate:seq.lastModifiedDate];

        if (![self isLocalItemSynced:seq]) {
            cell.actionButton.alpha = 1;
        }
        else {
            cell.statusImage.alpha = 1;
        }
    }
    
	return cell;
}	


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0);
}



-(void)actionButtonPressed:(UIButton*)sender {
    pressedTag = (int)sender.tag;
    NSInteger section = sender.tag/1000-1;
    NSInteger row = sender.tag%1000;
    if (section == 0 ) {
        DBFILESMetadata *item = remoteContent[row];
        if ([item isKindOfClass:[DBFILESFolderMetadata class]]) {
            DBFILESFolderMetadata *folderMetadata = (DBFILESFolderMetadata *)item;
            path = folderMetadata.pathLower;
            [self requestRemoteContent];
        }
        else {
            if (appDelegate.localFiles.count>=10) {
                [[UIApplication sharedApplication] showAlertWithTitle: @"Warning" message: @"There's no more space left in this folder"];
                return;
            }
            NSString *message = [NSString stringWithFormat:@"Download \"%@\" to your iPad?",[item.name stringByDeletingPathExtension]];
            [[UIApplication sharedApplication] showConfirmAlertWithTitle:@"Confirmation" message:message actionTitle: @"OK" onCompletion:^{
                [self handleAction: pressedTag];
            }];
        }
    }
    else {
        
        CateBean *selectedBean = content[row];
        NSString *message = [NSString stringWithFormat:@"Upload \"%@\" to Dropbox folder?",selectedBean.name];
        [[UIApplication sharedApplication] showConfirmAlertWithTitle:@"Confirmation" message:message actionTitle: @"OK" onCompletion:^{
            [self handleAction: pressedTag];
        }];
    }
}

-(void)handleAction:(NSInteger)tag {
    NSInteger section = tag/1000-1;
    NSInteger row = tag%1000;
    if (section == 1) {
       CateBean *selectedBean = content[row];
        loader.currentBean = selectedBean;
        [loader uploadBeanAtPath:path];
    }
    else {
        DBFILESMetadata *item = remoteContent[row];
        [loader downloadBeanFromPath:item.pathLower];
    }
}


-(void)beanDownloaderDidFailed {
    
}

-(void)beanDownloaderDidSuccess {
    [tableView reloadData];
    [self requestRemoteContent];

}
-(void)beanUploaderDidFailed {
    
}

-(void)beanUploaderDidSuccess {
    [self requestRemoteContent];
}



@end
