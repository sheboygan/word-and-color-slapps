//
//  RecordAudioViewController.h
//  Game
//
//  Created by Zorro on 16/11/2010.
//  Copyright 2010 Cosoft. All rights reserved.
//

#import "CommonVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnit.h>
#import "ImagesFinderVC.h"
@class CategoryBean;

@protocol RecordAudioViewControllerDelegate<NSObject>
@optional
-(void)newRecordDidFinish:(CategoryBean*)cateBean;
@end



@interface RecordAudioViewController : CommonVC<UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate, ImageFinderProtocol> {
	id<RecordAudioViewControllerDelegate> __weak delegate;
	
	IBOutlet UIImageView *image;
	UIImagePickerController *imgPicker;
	NSMutableDictionary *recordSetting;
	NSString *recorderFilePath;
	AVAudioRecorder *recorder;
	AVAudioPlayer *audioPlayer;
	
	UIProgressView *upv;
	NSTimer *timer;
	UITextField *texts;
	UILabel *labels;
	
	UISwitch *switchs;
	
	BOOL image_yes;
	BOOL sound_yes;
	BOOL letter_yes;
	BOOL b_change;
	
	BOOL newSound;
	
	NSData *_sound;
	NSInteger *_soundLen;
	NSString *_titles;
	
	NSInteger _id;
	NSInteger _category;
	NSInteger hide;
	
	BOOL proess_status;
	float ms;
	IBOutlet UIButton *camera;
	IBOutlet UIButton *btstop;
	IBOutlet UIButton *btPlay;
	IBOutlet UIButton *btRecord;
	UIPopoverController *popoverController;
	CategoryBean *categoryBean;
	IBOutlet UIButton *btCamera;
}

@property (weak) id<RecordAudioViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) IBOutlet UIProgressView *upv;
@property (nonatomic, strong) IBOutlet UITextField *texts;
@property (nonatomic, strong) IBOutlet UILabel *labels;
@property (nonatomic, strong) IBOutlet NSData *_sound;
@property (nonatomic, strong) IBOutlet NSString *_titles;
@property (nonatomic, strong) IBOutlet UISwitch *switchs;

@property (nonatomic) NSInteger *_soundLen;
@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger _category;
@property (nonatomic) NSInteger hide;
@property (nonatomic,strong) IBOutlet UIButton *camera;


- (void) ShowAlertMessage:(NSString *)Message AlertTitle:(NSString *)title;
- (IBAction) SelectImage:(id)sender;
- (IBAction) handleTimer:(id)sender;
- (IBAction) startRecording;
- (IBAction) uploadData: (id)sender;
- (IBAction) HiddenKeyWords:(id)sender;
- (IBAction) playSound:(id)sender;
- (IBAction) enableCustomize;
- (IBAction) stop: (id)sender;

-(void)updateCategorysDb: (CategoryBean *)cateBean;
-(void)createCategoryDb: (CategoryBean *)cateBean;

-(UIImage *)resizeImage:(UIImage *)imagees :(NSInteger) width :(NSInteger) height;
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
- (UIImage *)scale:(UIImage *)imagees toSize:(CGSize)size;

-(void)getcategoryBeanFromDb:(NSInteger)s_id;

@end
