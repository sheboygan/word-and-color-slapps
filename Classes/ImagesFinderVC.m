//
//  ImagesFinderVC.m
//  Question Sleuth
//
//  Created by Alexey Kuchmiy on 15.09.12.
//  Copyright (c) 2012 Alexey Kuchmiy. All rights reserved.
//

#import "ImagesFinderVC.h"
#import "NSString+SBJson.h"
#import "ImageResultCell.h"
#import "ImageItem.h"
@interface ImagesFinderVC ()

@end

@implementation ImagesFinderVC
@synthesize searchBar;
@synthesize table;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    content = [[NSMutableArray alloc] init];
    numberOfColumns = 3;
    engine = [[MKNetworkEngine alloc] initWithHostName:@"api.datamarket.azure.com" customHeaderFields:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoDownloaded) name:@"photoDownloaded" object:nil];
    [searchBar becomeFirstResponder];
    NSString* saved = [[NSUserDefaults standardUserDefaults] objectForKey: @"lastSearch"];
    searchBar.text = saved;
}
- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }

-(void)viewWillDisappear:(BOOL)animated {
    if (searchBar.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setObject: searchBar.text forKey: @"lastSearch"];
    }
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTable:nil];
    actView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)donePressed:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)asearchBar {
    [self.view endEditing:YES];
    [self requestImages];
    [asearchBar resignFirstResponder];
}

-(void)photoDownloaded {
    for (ImageResultCell *cell in table.visibleCells) {
        NSIndexPath *indexPath = [table indexPathForCell:cell];
        for (int i=0; i<numberOfColumns; i++) {
            [self setupCell:cell forRow:indexPath.row forIndex:i];
        }
    }
}

-(void)requestImages {
    NSString *searchTerm = [searchBar.text stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *requestString = [NSString stringWithFormat:@"Data.ashx/Bing/Search/v1/Composite?Sources=%%27image%%27&Query=%%27%@%%27&$top=500&$format=Json",searchTerm];
    [content removeAllObjects];
    [actView startAnimating];
    
    MKNetworkOperation *op = [engine operationWithPath:requestString];
    [op setUsername:@"" password:@"FcSLgemHXMM8wIKGzapsEDFDjOocqxkIw3/LrOZisJE="];
    
    [op onCompletion:^(MKNetworkOperation *operation) {
        NSArray *response = [[operation responseString]JSONValue][@"d"][@"results"];
        NSArray *images = response[0][@"Image"];
        for (NSDictionary *oneItem in images) {
            ImageItem *new = [[ImageItem alloc] init];
            new.thumbURL = oneItem[@"Thumbnail"][@"MediaUrl"];
            new.sourceURL = oneItem[@"MediaUrl"];
            [content addObject:new];
        }
        [table reloadData];
        [actView stopAnimating];
    }
     onError:^(NSError *error) {
         [actView stopAnimating];
         
         [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message:error.localizedDescription];
    }];
    [engine enqueueOperation:op];
    
}



-(void)selectPressed:(UIButton*)sender {

    if ([actView isAnimating]) {
        return;
    }
    ImageItem *curItem = content[sender.tag];
    if (curItem.sourcePath.length>0) {
        
        UIImage* selectedImage = [UIImage imageWithContentsOfFile: curItem.sourcePath];
        [_delegate imageFinderDidSelectImage: selectedImage];
        [self dismissViewControllerAnimated: YES completion: nil];
//        EditTokenPositionVC *edit = [[EditTokenPositionVC alloc] init];
//        Token *newToken = [[Token alloc] init];
//        newToken.userImagePath = curItem.sourcePath;
//        CFUUIDRef theUUID = CFUUIDCreate(NULL);
//        CFStringRef randomString = CFUUIDCreateString(NULL, theUUID);
//        CFRelease(theUUID);
//        newToken.ID = randomString;
//        [newToken useToken];
//
//        edit.curToken = newToken;
//        edit.curCategory = _curCategory;
//        [self.navigationController pushViewController:edit animated:YES];
//        [edit release];
//        [newToken release];
    }
    else
    {
        [actView startAnimating];
        NSString *host = [curItem.sourceURL pathComponents][1];
        MKNetworkEngine *photoDownloader = [[MKNetworkEngine alloc] initWithHostName:host customHeaderFields:nil];
        MKNetworkOperation *op = [photoDownloader operationWithURLString:curItem.sourceURL];
        [op onCompletion:^(MKNetworkOperation *operation) {
            [actView stopAnimating];
            UIImage *photo = [UIImage imageWithData:operation.responseData];
            if (photo) {
                NSString *folder = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                NSString *fileName = [NSString stringWithFormat:@"bingOriginal-%@",[curItem.sourceURL lastPathComponent]];
                NSString *filePath = [folder stringByAppendingPathComponent:fileName];
                [operation.responseData writeToFile:filePath atomically:YES];
                curItem.sourcePath = filePath;
                [self selectPressed:sender];
            }
            else
            {
                [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: @"Error saving image"];
            }
        }
                 onError:^(NSError *error) {
                     [actView stopAnimating];
                     [[UIApplication sharedApplication] showAlertWithTitle: @"Error" message: @"Error saving image"];
                 }];
        [photoDownloader enqueueOperation:op];

    }
}

#pragma mark UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil((content.count+(numberOfColumns-1))/numberOfColumns);
}



-(void)setupCell:(ImageResultCell*)oneCell forRow:(NSInteger)row forIndex:(NSInteger)index {
    NSString *uiIndex = [NSString stringWithFormat:@"%i",(int)index+1];
	
	UIImageView *i = [oneCell valueForKey:[NSString stringWithFormat:@"i%@",uiIndex]];
	UIButton *select = [oneCell valueForKey:[NSString stringWithFormat:@"b%@",uiIndex]];
	UIActivityIndicatorView *act = [oneCell valueForKey:[NSString stringWithFormat:@"a%@",uiIndex]];
	UIView *holderView = [oneCell valueForKey:[NSString stringWithFormat:@"c%@",uiIndex]];
	NSInteger itemIndex = numberOfColumns*row+index;
    select.tag = itemIndex;
    if (itemIndex>=[content count]) {
        holderView.alpha = 0;
        return;
    }
    holderView.alpha = 1;
    ImageItem *curItem = content[itemIndex];
    i.image = [UIImage imageWithContentsOfFile:curItem.thumbPath];
    if (!i.image) {
        [curItem downloadThumb];
    }
    if (curItem.isLoading)
        [act startAnimating];
    else
        [act stopAnimating];
}



- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
	
    ImageResultCell* cell = (ImageResultCell *)[atableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		NSArray *cellsArray = [[NSBundle mainBundle] loadNibNamed:@"ImageResultCell" owner:self options:nil];
		cell = [cellsArray lastObject];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.b1 addTarget:self action:@selector(selectPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.b2 addTarget:self action:@selector(selectPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.b3 addTarget:self action:@selector(selectPressed:) forControlEvents:UIControlEventTouchUpInside];

	}
	for (int i=0; i<numberOfColumns; i++) {
		[self setupCell:cell forRow:indexPath.row forIndex:i];
	}
    return cell;
}


@end
