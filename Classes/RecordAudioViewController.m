    //
//  RecordAudioViewController.m
//  Game
//
//  Created by Zorro on 16/11/2010.
//  Copyright 2010 Cosoft. All rights reserved.
//

#import "RecordAudioViewController.h"
#import "GameAppDelegate.h"
#import "CategoryBean.h"
#import "ImagesFinderVC.h"
#import "UIImage+Resize.h"
#import "UIApplication+Navigation.h"

@implementation RecordAudioViewController

@synthesize imgPicker;
@synthesize upv;
@synthesize texts;
@synthesize _id,_sound,_soundLen,_titles,labels,hide;
@synthesize switchs;
@synthesize camera;
@synthesize _category;
@synthesize popoverController;
@synthesize delegate;

-(BOOL)isExistsFile:(NSString *)filepath{
	
	NSFileManager *filemanage = [NSFileManager defaultManager];
	
	return [filemanage fileExistsAtPath:filepath];
	
}

-(void)ShowAlertMessage:(NSString *)Message AlertTitle:(NSString *)title {
    if ([title isEqualToString: @"OK"]) {
        [[UIApplication sharedApplication] showAlertWithTitle:title message:Message  onCompletion:^{
            [self dismissViewControllerAnimated: YES completion: nil];
        }];
        return;
    }
    [[UIApplication sharedApplication] showAlertWithTitle:title message:Message];
}


- (IBAction) enableCustomize{
	NSInteger indexs = self.switchs.on;
	hide = indexs;
}

-(IBAction)back: (id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

-(IBAction) uploadData: (id)sender {
	if([self.texts.text isEqual:@""]){
        [self ShowAlertMessage:NSLocalizedString(@"Please add a name for the image", nil) AlertTitle:@""];
	}else if([self.texts.text length]>=50){
		[self ShowAlertMessage:@"The name should be less than 50 charcter!" AlertTitle:@""];
	}
    
	else if(!image.image){
		[self ShowAlertMessage:NSLocalizedString(@"Please select an image from your photo library", nil) AlertTitle:@""];
	}else{
		if (letter_yes && sound_yes && image_yes && (!b_change) && [self.texts.text isEqualToString:categoryBean.name]) {
			//[self ShowAlertMessage:@"No changes!" AlertTitle:@"Info"];
			[self back: nil];
            return;
		}
		NSData *audioData;
		if (!newSound) {
			audioData = _sound;
		}else {
			NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
				//NSError *err = nil;
			audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:nil];
		}
		//_records.hide = hide;
//		
//		[db insertIntoDatabase:self._titles images:image.image car_id:self._id  letter:self.texts.text sound_file:audioData _hide:hide];
		
        // get current date/time
		NSDate *today = [NSDate date];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		// display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateFormat:@"MMddyyyyHHmmss"];
		NSString *currentTime = [dateFormatter stringFromDate:today];
	//	NSLog(@"%@", currentTime);

		
		CategoryBean *cBean = [[CategoryBean alloc] init];
		cBean.name = self.texts.text;
		if (newSound) {
			cBean.audio = [NSString stringWithFormat:@"s_%@", currentTime];
            [audioData writeToFile:[cBean audioFilePath] atomically:NO];

		}else {
			cBean.audio = categoryBean.audio;
		}
		cBean.image = [NSString stringWithFormat:@"i_%@", currentTime];
		
        
		
		NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image.image)];
		[data1 writeToFile:[cBean imageFilePath] atomically:NO];
		
		
		if (_category==0) {   //new category
			[self.delegate newRecordDidFinish:cBean];
			[self back: nil];
		}else if (_id ==0) {  //new image under a certain category
			[self createCategoryDb:cBean];
			[self back: nil];
		}else {
			NSFileManager *fileManager = [[NSFileManager alloc] init];
            [fileManager removeItemAtPath:[categoryBean audioFilePath] error:NULL];
			[fileManager removeItemAtPath:[categoryBean imageFilePath] error:NULL];
			[self updateCategorysDb:cBean];
			[self ShowAlertMessage:@"Changes Saved!" AlertTitle:@"OK"];
		}
	}
	
}

-(IBAction)handleTimer:(id)sender{
	[upv setProgress:ms];
	NSString *strtemp = [NSString stringWithFormat:@"%0.1f", ms];
	if ([strtemp isEqualToString:@"1.1"]) {
		[timer invalidate];
		timer = nil;
		if (recorder) {
			[recorder stop];
		}
		if (audioPlayer) {
			[audioPlayer stop];
		}
		ms=0;
		[upv setProgress:ms];
		btPlay.enabled = YES;
		btRecord.enabled = YES;
	}
	if(proess_status){
		//NSLog(@"%0.1f", ms);
		ms = ms +0.1f;
	}
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	ms = 0;
	hide = 1;
	proess_status = NO;
	image_yes = NO;
	sound_yes = NO;
	letter_yes = NO;
	b_change = NO;
	newSound = NO;
	self.camera.hidden = YES;
	labels.text = self._titles;
	recordSetting = [[NSMutableDictionary alloc] init];
		//self.navigationController.navigationBarHidden = YES;
	UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain  target:self action:@selector(uploadData:)];
	self.navigationItem.rightBarButtonItem = stopButton;
	
	self.view.backgroundColor = [UIColor clearColor];
	self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.allowsEditing = YES;
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		btCamera.hidden = YES;
		btCamera.enabled = NO;
	}
	
	self.imgPicker.delegate = self;
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
	self.popoverController = popover;          
	popoverController.delegate = self;

	[self getcategoryBeanFromDb:_id];

	if (!categoryBean.name) {
		
	}else{
		if(categoryBean.name){
			texts.text = categoryBean.name;
			letter_yes = YES;
		}
		NSString *sound_path = [categoryBean audioFilePath];
		
			//NSURL *url = [NSURL fileURLWithPath:sound_path];
		
		if([self isExistsFile:sound_path]){
			sound_yes = YES;
			_sound = [[NSData alloc]init];
			NSURL *url = [NSURL fileURLWithPath: sound_path];
				//NSError *err = nil;
			_sound = [NSData dataWithContentsOfFile:[url path] options: 0 error:nil];
		}
		
		NSString *pngFilePath = [categoryBean imageFilePath];		
		
		if([self isExistsFile:pngFilePath]){
			image_yes = YES;
			image.image = [UIImage imageWithContentsOfFile:pngFilePath];
		}
		image.contentMode = UIViewContentModeScaleAspectFit;
        image.clipsToBounds = YES;
		//NSLog(@"%@", sound_path);
		//NSLog(@"%@", pngFilePath);
	}
}
	//Hidden the keywords function for the app
-(IBAction)HiddenKeyWords:(id)sender{
	[self.texts resignFirstResponder];
}



- (void)dealloc {
//	[camera release];

	if (timer) {
		[timer invalidate];
	}
}

#pragma mark Audio operation 
//the action for the start recording button;
- (IBAction) startRecording{
	b_change = YES;
	proess_status = YES;
	self.view.userInteractionEnabled = YES;
	//self.view.userInteractionEnabled = NO;
	btPlay.enabled = NO;
	btRecord.enabled = NO;
	btstop.enabled = YES;
	ms = 0;
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *err = nil;
//    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
//	[audioSession setActive:YES error:&err];

	[recordSetting removeAllObjects];
	
	[recordSetting setValue :@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
	[recordSetting setValue:@44100.0f forKey:AVSampleRateKey]; 
	[recordSetting setValue:@2 forKey:AVNumberOfChannelsKey];
	
	[recordSetting setValue :@16 forKey:AVLinearPCMBitDepthKey];
	[recordSetting setValue :@NO forKey:AVLinearPCMIsBigEndianKey];
	[recordSetting setValue :@NO forKey:AVLinearPCMIsFloatKey];
	
	
	
	// Create a new dated file
	//NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	//	NSString *caldate = [now description];
	recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, @"tmp"];
	
	NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
	err = nil;
	recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
	if(!recorder){
        [[UIApplication sharedApplication] showAlertWithTitle: @"Warning" message:err.localizedDescription];
        return;
	}
	
	//prepare to record
	[recorder setDelegate:self];
	[recorder prepareToRecord];
	recorder.meteringEnabled = YES;
	
	// start recording
	[recorder record];
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.5f
											 target: self
										   selector: @selector(handleTimer:)
										   userInfo: nil
											repeats: YES];
	//[recorder recordForDuration:(NSTimeInterval) 5];
}
-(void)viewWillDisappear:(BOOL)animated{
	self.view.userInteractionEnabled = YES;
	if (recorder) {
		[recorder stop];
	}
	if (audioPlayer) {
		[audioPlayer stop];
	}
	
	btPlay.enabled = YES;
	btRecord.enabled = YES;
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	ms=0;
	[upv setProgress:ms];
	proess_status = NO;
	
}
- (IBAction) stop: (id)sender
{
	self.view.userInteractionEnabled = YES;
	if (recorder) {
		[recorder stop];
	}
	if (audioPlayer) {
		[audioPlayer stop];
	}
	
	btPlay.enabled = YES;
	btRecord.enabled = YES;
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	ms=0;
	[upv setProgress:ms];
	proess_status = NO;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag{
	//[timer invalidate];
	//NSLog(@"OK");
	ms=0;
	[upv setProgress:ms];
	proess_status = NO;
	//NSLog(@"111");
	if (timer) {
		//NSLog(@"222");
		[timer invalidate];
		//NSLog(@"333");
		timer = nil;
	}
	//NSLog(@"444");
	btPlay.enabled = YES;
	btRecord.enabled = YES;
	self.view.userInteractionEnabled = YES;
	newSound = YES;
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	//NSLog(@"play stop");
	ms=0;
	[upv setProgress:ms];
	proess_status = NO;
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	self.view.userInteractionEnabled = YES;
	//NSLog(@"play enable");
	btPlay.enabled = YES;
	btRecord.enabled = YES;
}

-(IBAction)playSound:(id)sender{
	btPlay.enabled = NO;
	btRecord.enabled = NO;
	
	//self.view.userInteractionEnabled = NO;
	
	if(newSound){
		ms = 0;
		proess_status = YES;
		NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
		audioPlayer = [[AVAudioPlayer alloc] 
							  initWithContentsOfURL: [NSURL fileURLWithPath:[url path]] error:NULL];
		audioPlayer.numberOfLoops=0;
		audioPlayer.delegate = self;
		[audioPlayer prepareToPlay];
		[audioPlayer play];
		timer = [NSTimer scheduledTimerWithTimeInterval: 0.5f
												 target: self
											   selector: @selector(handleTimer:)
											   userInfo: nil
												repeats: YES];
		//[tmp release];
	}else {
		if(_sound){
			ms = 0;
			proess_status = YES;
			NSString *sound_path = [categoryBean audioFilePath];
			//NSURL *url = [NSURL fileURLWithPath:sound_path];
			
			if([self isExistsFile:sound_path]){
				//AVAudioPlayer *tmp = [[AVAudioPlayer alloc] initWithData:_sound error:NULL];
				NSURL *url = [NSURL fileURLWithPath: sound_path];
				audioPlayer = [[AVAudioPlayer alloc] 
									  initWithContentsOfURL: [NSURL fileURLWithPath:[url path]] error:NULL];
				
				audioPlayer.numberOfLoops=0;
				audioPlayer.delegate = self;
				[audioPlayer prepareToPlay];
				[audioPlayer play];
				timer = [NSTimer scheduledTimerWithTimeInterval: 0.5f
														 target: self
													   selector: @selector(handleTimer:)
													   userInfo: nil
														repeats: YES];
			}else{
				self.view.userInteractionEnabled = YES;
	            btPlay.enabled = YES;
				btRecord.enabled = YES;
				[self ShowAlertMessage:@"Please record your audio first!" AlertTitle:@"Warning"];
			}
			//[tmp release];
		}else {
			self.view.userInteractionEnabled = YES;
			btPlay.enabled = YES;
			btRecord.enabled = YES;
			[self ShowAlertMessage:@"Please record your audio first!" AlertTitle:@"Warning"];
		}
		
	}
	
}

#pragma mark DB operation
-(void)getcategoryBeanFromDb:(NSInteger)s_id {
	
	sqlite3 *db = [appDelegate getDatabase];
	categoryBean = [[CategoryBean alloc] init];
	if (s_id==0) {
		return;
	}
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "select name, image, audio from  image where id=?";
        if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			categoryBean = nil;
			// NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, (int)s_id);
			if (sqlite3_step(statements) == SQLITE_ROW) {
				categoryBean.record_ID = s_id;
				if(sqlite3_column_text(statements,0)){
					categoryBean.name = @((char *)sqlite3_column_text(statements,0));
				}
				if(sqlite3_column_text(statements,1)){
					categoryBean.image = @((char *)sqlite3_column_text(statements,1));
				}
				if(sqlite3_column_text(statements,2)){
					categoryBean.audio = @((char *)sqlite3_column_text(statements,2));		
				}
			}
			sqlite3_finalize(statements);
		}
    }
}


-(void)updateCategorysDb: (CategoryBean *)cateBean {
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "update image set name=?,image=?,audio=? where id=?";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_int(statements, 4, (int)_id);
		sqlite3_bind_text(statements, 1, [cateBean.name UTF8String], -1, SQLITE_TRANSIENT);	
		sqlite3_bind_text(statements, 2, [cateBean.image UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statements, 3, [cateBean.audio UTF8String], -1, SQLITE_TRANSIENT);
    }
	int success = sqlite3_step(statements);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
    }    	
	sqlite3_finalize(statements);
	statements = nil;
}

-(void)createCategoryDb: (CategoryBean *)cateBean
{
	sqlite3 *db = [appDelegate getDatabase];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		static char *sql = "INSERT INTO image(name, image, audio, category) VALUES(?,?,?,?)";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(statements, 1, [cateBean.name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statements,2, [cateBean.image UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statements, 3, [cateBean.audio UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statements, 4, (int)_category);
	}
	int success = sqlite3_step(statements);
	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
	} 
	// All data for the book is already in memory, but has not be written to the database
	sqlite3_finalize(statements);
	statements = nil;
}

#pragma mark Image Operation

// the action for the image picker
-(IBAction)SelectImage:(id)sender{
	
	switch ([sender tag]) {
		case 0:
			self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
		case 1:
			self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		case 2:
        {
            [self.view endEditing: NO];
            ImagesFinderVC* finder = [[ImagesFinderVC alloc] init];
            finder.delegate = self;
            finder.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController: finder animated: YES completion: nil];
            return;
			break;
        }
	}
		
	
    [popoverController presentPopoverFromRect:CGRectMake(180, 620, 290, 48)
									   inView:self.view
					 permittedArrowDirections:UIPopoverArrowDirectionDown
									 animated:YES];
}

- (void)imageFinderDidSelectImage:(UIImage *)newImage
{
    image.image = newImage;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [popoverController dismissPopoverAnimated:YES];
	[[picker parentViewController] dismissViewControllerAnimated: YES completion: nil];
    b_change = YES;
	UIImage *selectedImage = info[UIImagePickerControllerEditedImage]; 	
	if (!selectedImage)
		selectedImage = info[UIImagePickerControllerOriginalImage];
	
	UIImage *croppedPhoto = [self downscaleImage:selectedImage];
    image.image = croppedPhoto;
    if (croppedPhoto.size.width<50)
        image.image = selectedImage;

}

-(UIImage*)downscaleImage:(UIImage*)processImage {
	
	CGFloat originalWidth = processImage.size.width;
	CGFloat originalHeight = processImage.size.height;
	CGFloat smallerDimensionMultiplier;
	CGFloat newWidth;
	CGFloat newHeight;
	if (originalWidth > originalHeight) {
		smallerDimensionMultiplier = originalHeight / originalWidth;
		newWidth = 500;
		newHeight = newWidth * smallerDimensionMultiplier;
	}
	else {
		smallerDimensionMultiplier = originalWidth / originalHeight;
		newHeight =  500;
		newWidth = newHeight * smallerDimensionMultiplier;
	}
	CGSize newSize;
	newSize.width = newWidth;
	newSize.height = newHeight;
	
	UIImage *resultImage = [processImage th_resizedImage:newSize interpolationQuality:kCGInterpolationHigh];
    
    return resultImage;
    
}

- (UIImage*)scaleImage:(UIImage*)anImage withEditingInfo:(NSDictionary*)editInfo{
	
	CGRect sz = CGRectMake(0.0f, 0.0f, 55.0f, 55.0f);
	UIImage *newImage =  [self imageByCropping:anImage toRect:sz];
	return newImage;
}

- (UIImage *)scale:(UIImage *)imagees toSize:(CGSize)size 
{ 
    UIGraphicsBeginImageContext(size); 
    [imagees drawInRect:CGRectMake(0, 0, size.width, size.height)]; 
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext(); 
    UIGraphicsEndImageContext(); 
    return scaledImage; 
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	//create a context to do our clipping in
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClipToRect( currentContext, clippedRect);
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
								 rect.origin.y * -1,
								 imageToCrop.size.width,
								 imageToCrop.size.height);
	
	//draw the image to our clipped context using our offset rect
	CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

-(UIImage *)resizeImage:(UIImage *)imagees :(NSInteger) width :(NSInteger) height {
	
	return nil;	
}

#pragma mark UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[texts resignFirstResponder];
	return YES;
}

@end
