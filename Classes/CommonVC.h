//
//  CommonVC.h
//  Game
//
//  Created by Alexey Kuchmiy on 16.02.14.
//
//

#import <UIKit/UIKit.h>
#import "GameAppDelegate.h"
@import GoogleMobileAds;

@interface CommonVC : UIViewController <GADFullScreenContentDelegate, GADBannerViewDelegate>
{
    GameAppDelegate* appDelegate;
    IBOutlet UITableView *tbView;
    UIView* topContainer;
}

@property (nonatomic, retain) GADBannerView* bannerAdMob;
@property (strong) GADInterstitialAd* interstitial;

-(void)ShowAlertMessage:(NSString *)Message AlertTitle:(NSString *)title;
-(IBAction)back: (id)sender;

@end
