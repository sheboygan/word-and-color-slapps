//
//  GameAppDelegate.h
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright CoSoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "CustomNavigationController.h"
#import "SharedObjects.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@class MainMenuVC;

@interface GameAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	CustomNavigationController *navController;
	sqlite3 *database;
}

- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
-(sqlite3 *) getDatabase;

@property (nonatomic, strong) NSMutableArray *localFiles;
@property (nonatomic, assign) sqlite3* database;
@property (nonatomic, assign) int currentCategoryId;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet CustomNavigationController *navController;
- (void) openDropboxBrowser;
- (void) presentAppStoreFullVersion;

@end

