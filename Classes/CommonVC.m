//
//  CommonVC.m
//  Game
//
//  Created by Alexey Kuchmiy on 16.02.14.
//
//

#import "CommonVC.h"
#import "SettingsVC.h"
#import "UIApplication+Navigation.h"

@interface CommonVC ()
{
    BOOL loadingAd;
}
@end

@implementation CommonVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = (GameAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor blackColor];
    
    
    if (![SharedObjects objects].isPro || [SharedObjects objects].isColorSlapps)
    {
        [self initGoogleAds];
    
        if ([self isKindOfClass: [SettingsVC class]] && arc4random()%2 == 1)
        {
            self.interstitial = [[GADInterstitial alloc] initWithAdUnitID: [self interstitialId]];
            self.interstitial.delegate = self;
            GADRequest* request = [GADRequest request];
            [self.interstitial loadRequest: request];
            loadingAd = YES;
        }
    }
}

- (NSString*) interstitialId
{
    if ([SharedObjects objects].isColorSlapps)
    {
        return @"ca-app-pub-2383666392920244/1013198088";
    }
    if (![SharedObjects objects].isPro)
    {
        return @"ca-app-pub-2383666392920244/4290212080"; // Lite version
    }
    return @"";
}

- (NSString*) bottomBannerId
{
    if ([SharedObjects objects].isColorSlapps)
    {
        return @"ca-app-pub-2383666392920244/8536464886";
    }
    if (![SharedObjects objects].isPro)
    {
        return @"ca-app-pub-2383666392920244/4290212080"; // Lite version
    }
    return @"";
}

- (void) initGoogleAds
{
    self.bannerAdMob = [[GADBannerView alloc] initWithAdSize: kGADAdSizeSmartBannerLandscape];
    self.bannerAdMob.adUnitID = [self bottomBannerId];
    self.bannerAdMob.delegate = self;
    self.bannerAdMob.rootViewController = self;
    
    GADRequest* request = [GADRequest request];
    request.testDevices = @[@"a72c7feaa9e53d279ec3533efdb48197"];
    
    [self.bannerAdMob loadRequest: request];
}

#pragma mark - GoogleAdMob banners delegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    UIView* fullscreen = self.view;

    if (!topContainer)
    {
        topContainer = [[UIView alloc] initWithFrame: fullscreen.bounds];
        [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [topContainer addSubview: obj];
        }];
        topContainer.clipsToBounds = YES;
        [self.view addSubview: topContainer];
    }
    
    self.bannerAdMob.frame = CGRectMake(0, fullscreen.bounds.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height);
    [self.view addSubview: self.bannerAdMob];

    
    [UIView animateWithDuration: 0.4 animations:^{
        CGRect r = topContainer.frame;
        r.size.height = fullscreen.frame.size.height - self.bannerAdMob.frame.size.height;
        topContainer.frame = r;
    }];

    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    [UIView animateWithDuration: 0.4 animations:^{
        CGRect r = topContainer.frame;
        r.size.height = self.view.frame.size.height;
        topContainer.frame = r;
    }];
    [self.bannerAdMob removeFromSuperview];
}


-(void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    loadingAd = NO;
}

-(void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    loadingAd = NO;
    [self.interstitial presentFromRootViewController:self];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (UIInterfaceOrientationIsLandscape(toInterfaceOrientation));
}

-(IBAction)back: (id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)ShowAlertMessage:(NSString *)Message AlertTitle:(NSString *)title
{
    [[UIApplication sharedApplication] showAlertWithTitle: title message: Message];
}


@end
