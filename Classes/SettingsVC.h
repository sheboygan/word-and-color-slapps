//
//  SettingViewController.h
//  Game
//
//  Created by Sunny on 11/4/10.
//  Copyright 2010 CoSoft. All rights reserved.
//

#import "CommonVC.h"
#import <MessageUI/MFMailComposeViewController.h>


typedef NS_ENUM(NSInteger, VisualType)
{
    VisualTypeBasic,
    VisualTypeVehicles,
    VisualTypeFarm
};

@interface SettingsVC : CommonVC <MFMailComposeViewControllerDelegate>
{
    IBOutlet UIImageView *mainBgView;
	IBOutlet UIButton *btTellFriend;
	IBOutlet UIButton *btEdit;
	IBOutlet UISegmentedControl *segTurns;
	IBOutlet UISwitch *swAdvance;
	IBOutlet UISwitch *swPromote;
	IBOutlet UISwitch *swSounds;
	IBOutlet UISwitch *swVisual;
	IBOutlet UISwitch *swIncorrect;
	IBOutlet UIButton *btVisual;
	
	IBOutlet UILabel *lbTurns;
	IBOutlet UILabel *lbMode;
	IBOutlet UILabel *lbQPromote;
	IBOutlet UILabel *lbIncorrect;
	IBOutlet UILabel *lbCorrect;
	IBOutlet UILabel *lbVisual;
	IBOutlet UILabel *lbTheme;
	
	IBOutlet UIButton *btInfo;
    __weak IBOutlet UIButton *butRestore;
    
	VisualType visualType;
    BOOL isFarmPurchased;
    BOOL isVehiclesPurchased;
}

@property (strong) NSArray* content;
@property (strong) UIImageView* preview;
@property (strong) UIActivityIndicatorView* actView;

-(IBAction)visualList: (id)sender;

-(IBAction)edit: (id)sender;
-(IBAction)info:(id)sender;

-(IBAction)changeTurns: (id)sender;
-(IBAction)changeAdvance: (id)sender;
-(IBAction)changePromote: (id)sender;
-(IBAction)changeSounds: (id)sender;
-(IBAction)changeVisual: (id)sender;
-(IBAction)changeIncorrect: (id)sender;
-(IBAction)share: (id)sender;
-(void)initUI;

-(void)saveType: (NSInteger)vsulType;
- (IBAction)onRestore:(id)sender;

@end
