//
//  ImagesFinderVC.h
//  Question Sleuth
//
//  Created by Alexey Kuchmiy on 15.09.12.
//  Copyright (c) 2012 Alexey Kuchmiy. All rights reserved.
//

#import "CommonVC.h"

@protocol ImageFinderProtocol <NSObject>

- (void) imageFinderDidSelectImage: (UIImage*) image;
@end

@interface ImagesFinderVC : CommonVC <UISearchBarDelegate, UITextFieldDelegate> {
    IBOutlet UIActivityIndicatorView *actView;
    MKNetworkEngine *engine;
    int numberOfColumns;
    NSMutableArray* content;
}
- (IBAction)donePressed:(id)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) id delegate;
@end
