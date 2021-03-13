//
//  PlayVC.m
//  Game
//
//  Created by Alexey Kuchmiy on 31.03.13.
//
//

#import "PlayVC.h"
#import "GameAppDelegate.h"
#import "CategoryBean.h"
#import "NSMutableArray+Shuffle.h"
#import <QuartzCore/QuartzCore.h>

static const int ReplayQuestionTimeout = 4;

@interface PlayVC ()

@end

@implementation PlayVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    options = [[NSMutableArray alloc] init];
    missedWords = [[NSMutableArray alloc] init];
    incorrectGuessCounter = 0;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(optionDidPress:)];
    [self.gameOptionsContainer addGestureRecognizer: tap];
    [self getSettings];
    [self initStyle];
    [self layoutOptions];
    [self getImagesfromDB];
    [self updateContent];
    
    if ([SharedObjects objects].isColorSlapps)
    {
        [self.viewResultsPrompt removeFromSuperview];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the button.
    if (self.gameOptionsContainer.userInteractionEnabled == NO) {
        return NO;
    }
    return YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    dismissed = YES;
    if (self.voPlayer)
    {
        self.voPlayer.delegate = nil;
        [self.voPlayer stop];
        self.voPlayer = nil;
    }
    if (self.effectsPlayer)
    {
        self.effectsPlayer.delegate = nil;
        [self.effectsPlayer stop];
        self.effectsPlayer = nil;
    }
    if (self.selectionPlayer)
    {
        self.selectionPlayer.delegate = nil;
        [self.selectionPlayer stop];
        self.selectionPlayer = nil;
    }
}

- (void) initStyle
{
    if(settingsThemeIndex == 2)  //farm pack
    {
        bgMain.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"farm background" ofType:@"png"]];
        [self.butPlayAgain setImage: nil forState: UIControlStateNormal];
        [self.butPlayAgain setImage: nil forState: UIControlStateHighlighted];
        self.butPlayAgain.frame = CGRectMake(867, 613, 92, 75);
    }else if(settingsThemeIndex == 1) {   //Vehicle
        bgMain.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vehicleBg" ofType:@"png"]];
        [self.butPlayAgain setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Vehicle Playagain" ofType:@"png"]] forState:UIControlStateNormal];
        self.butPlayAgain.frame = CGRectMake(835, 550, 178, 193);
        _txtTopTitle.textColor = [UIColor whiteColor];
    }else {
        bgMain.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bgPlay" ofType:@"png"]];
        [self.butPlayAgain setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Play Again Sunflower" ofType:@"png"]] forState:UIControlStateNormal];
        self.butPlayAgain.frame = CGRectMake(714, 298, 340, 450);
    }
    
    self.butNext.hidden = !settingsPracticeMode;
    self.txtWordsMissed.text = NSLocalizedString(@"Words missed", nil);
    self.statsContainer.hidden = YES;
    self.viewResultsPrompt.hidden = YES;

}

- (void) updateContent
{
    if (passedQuestions >= settingsNumberOfTurns)
    {
        [self animateWin];
        return;
    }

    NSPredicate* pre = [NSPredicate predicateWithFormat: @"b_Sel = YES"];
    NSArray* guessBeans = [options filteredArrayUsingPredicate: pre];
    if (questionIndex >= guessBeans.count)
    {
        questionIndex = 0;
    }
    
    CategoryBean* cBean = guessBeans[questionIndex];
    if (categoryID == 1)
    {
        NSString *strFindthe = NSLocalizedString(@"Find the", nil);
        NSString *animalName = NSLocalizedString(cBean.name, nil);
        _txtTopTitle.text = [NSString stringWithFormat:@"%@ %@", strFindthe, animalName];
        self.curGuessWordTitle = animalName;
    }
    else
    {
        NSString *strFind = NSLocalizedString(@"Find", nil);
        _txtTopTitle.text = [NSString stringWithFormat:@"%@ %@", strFind, cBean.name];
        self.curGuessWordTitle = cBean.name;
    }
    
    _txtTopTitle.hidden = settingsQuestionPrompt;

    NSString* correctImagePath = nil;
    if (categoryID == 1 || categoryID == 2)
        correctImagePath = [[NSBundle mainBundle] pathForResource: cBean.image ofType:@"png"];
    else
        correctImagePath = [cBean imageFilePath];
    
    NSMutableArray* imagePaths = [NSMutableArray array];
    [imagePaths addObject: correctImagePath];
    
    NSMutableArray* leftOptions = [NSMutableArray arrayWithArray: options];
    [leftOptions removeObject: cBean];
    [leftOptions shuffle];
    for (CategoryBean* b in leftOptions)
    {
        if (imagePaths.count >= self.level)
        {
            break;
        }
        NSString* imagePath = nil;
        if (categoryID == 1 || categoryID == 2)
            imagePath = [[NSBundle mainBundle] pathForResource: b.image ofType:@"png"];
        else
            imagePath = [b imageFilePath];
        
        if (![imagePaths containsObject: imagePath])
            [imagePaths addObject: imagePath];
        

    }
    
    [imagePaths shuffle];
    correctAnswerTag = (int)[imagePaths indexOfObject: correctImagePath] + 1;
    
    [imagePaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView* optionImage = (UIImageView*)[self.gameOptionsContainer viewWithTag: idx + 1];
        optionImage.image = [UIImage imageWithContentsOfFile: obj];
    }];
 
    
    [self playQuestionForCurrentIndex];
}

- (void) playQuestionForCurrentIndex
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(playQuestionForCurrentIndex) object: nil];

    if (!settingsQuestionPrompt)
        return;
    if (self.winAnimation.alpha != 0)
        return;
    NSPredicate* pre = [NSPredicate predicateWithFormat: @"b_Sel = YES"];
    NSArray* guessBeans = [options filteredArrayUsingPredicate: pre];
    
    CategoryBean* cBean = guessBeans[questionIndex];
    NSString* voFilepath = nil;
    if ((categoryID==1) || (categoryID==2)) 
        voFilepath = [[NSBundle mainBundle] pathForResource: cBean.audio ofType:@"wav"];
    else
        voFilepath = [cBean audioFilePath];
    [self playVoSound: voFilepath];
}

- (void) layoutOptions
{
    self.gameOptionsContainer.userInteractionEnabled = YES;
    self.butPlayAgain.alpha = 0;
    self.gameOptionsContainer.alpha = 1;
    [self.winAnimation stopAnimating];
    self.winAnimation.alpha = 0;
    
    
    int optionWidth = 264;
    
    int offsetX = 0;
    int offsetY = 0;
    
    int marginX = 50;
    int marginY = 15;
    int maxInRow = 3;
    

    if (self.level <= maxInRow)
    {
        offsetY = (optionWidth*2 + marginY)/2 - optionWidth/2;
    }
    
    switch (self.level)
    {
        case 1:
            offsetX = (optionWidth + marginX);
            break;

        case 2:
            offsetX = (optionWidth + marginX)/2;
            break;
        case 4:
            maxInRow = 2;
            offsetX = (optionWidth + marginX)/2;

            break;
        case 5:
            offsetX = (optionWidth*2 + marginX)/2 - optionWidth/2;
            break;
    }

    
    int counter = 0;
    int maxX = (optionWidth + marginX) * maxInRow - optionWidth;

    if (self.level == 4) {
        maxX += offsetX;
    }
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey: @"tag" ascending: YES];
    NSArray* sortedByTags = [self.gameOptionsContainer.subviews sortedArrayUsingDescriptors:@[sort]];
    for (UIImageView* option in sortedByTags)
    {
        if (option.tag == 0)
            continue;
        if (offsetX >= maxX)
        {
            offsetX = 0;
            if (self.level == 4)
            {
                offsetX = (optionWidth + marginX-2)/2;

            }
            offsetY += optionWidth + marginY;
            counter = 0;
        }
        option.alpha = 1;
        option.hidden = (option.tag > self.level);
        option.frame = CGRectMake(offsetX, offsetY, optionWidth, optionWidth);
        offsetX += optionWidth + marginX;
        counter ++;
        
    }
}

- (IBAction)optionDidPress:(id)sender
{
    CGPoint locationInView = [(UITapGestureRecognizer*)sender locationInView: self.gameOptionsContainer];
    
    UIImageView* iv = nil;
    for (UIImageView* option in self.gameOptionsContainer.subviews)
    {
        if (CGRectContainsPoint(option.frame, locationInView))
        {
            iv = option;
        }
    }
    if (!iv)
        return;
    
    if (iv.subviews.count == 1)
        return;
    
    if (iv.tag == correctAnswerTag)
    {
        [self.incorrectAnswerX removeFromSuperview];
        [self.gameOptionsContainer bringSubviewToFront: iv];
        
        float animationDelay = 0;
        if (settingsCorrectResponseVisual)
        {
            animationDelay = [self applyCorrectAnimation: iv];
        }
        else
        {
            animationDelay = 2;
            if (settingsCorrectResponseSounds)
            {
                [self playSelectionSound: @"applause8"];
                animationDelay = 3;
            }
        }
        self.gameOptionsContainer.userInteractionEnabled = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(playQuestionForCurrentIndex) object: nil];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, animationDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (self.winAnimation.alpha != 0)
            {
                return ;
            }
            if (!settingsPracticeMode)
            {
                questionIndex ++;
                passedQuestions ++;
                [self layoutOptions];
                [self updateContent];
            }
            else
            {
                [self layoutOptions];
                [self playQuestionForCurrentIndex];
            }
        });
    }
    else
    {
        self.gameOptionsContainer.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (!self.voPlayer.isPlaying)
            {
                self.gameOptionsContainer.userInteractionEnabled = YES;
            }
        });

        [self.voPlayer stop];
        if (settingsIncorrectResponse)
        {
            [iv addSubview: self.incorrectAnswerX];
            self.incorrectAnswerX.frame = iv.bounds;
            [self playSelectionSound: @"incorrect"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.incorrectAnswerX removeFromSuperview];
                [self playQuestionForCurrentIndex];

            });
        }
        
        incorrectGuessCounter ++;
        NSString* curWord = self.curGuessWordTitle;
        if (![missedWords containsObject: curWord])
            [missedWords addObject: curWord];
    }
}

- (float) applyCorrectAnimation: (UIImageView*) imageView
{
    float duration = 2;
    NSString* effectName = nil;

    if (settingsThemeIndex == 0)
    {
        
        [UIView beginAnimations:nil context:nil];

		int i = arc4random() % 5;
        switch (i) {
            case 0:
            {
                effectName = @"Funny_Cartoon_Sound";
                imageView.frame = CGRectMake(-120, -120, 0, 0);
                break;
            }
            case 1:
            {
                effectName = @"windchime_2";
                imageView.alpha = 0;
                duration = 2.5;
                break;
            }
            case 2:
            {
                effectName = @"MULTI_FUN_01";
                duration = 6;
                imageView.frame = CGRectMake(104, 788, 0, 0);
                break;
            }
            case 3:
            {
                effectName = @"Whoosh";
                CABasicAnimation* spinAnimation = [CABasicAnimation
                                                   animationWithKeyPath:@"transform.rotation"];
                spinAnimation.toValue = [NSNumber numberWithFloat:5*2*M_PI];
                spinAnimation.duration = duration;
                [imageView.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
                break;
            }
            case 4:
            {
                effectName = @"Rollover_19";
                CABasicAnimation *theAnimation;
                theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
                theAnimation.duration = duration;
                //theAnimation.repeatDuration = 2;
                //theAnimation.repeatCount = 3;
                theAnimation.removedOnCompletion = YES;
                theAnimation.fillMode = kCAFillModeBoth;
                theAnimation.autoreverses = NO;
                theAnimation.fromValue = @0.0f;
                theAnimation.toValue = @60.0f;
                [imageView.layer addAnimation:theAnimation forKey:@"rotateAnimation"];
                break;
            }
        }
        [UIView setAnimationDuration: duration];
		[UIView commitAnimations];
    }
    
    if (settingsThemeIndex == 2 || settingsThemeIndex == 1)
    {
        duration = 1.5;
        NSArray *beginNames = @[@"Cat", @"Chicken", @"Cow", @"Dog", @"Duck",
							   @"Goat", @"Horse", @"Pig",@"Rooster", @"Sheep"];
        NSString* extension = @"png";
        if (settingsThemeIndex == 1)
        {
            beginNames = @[@"clip", @"Bike", @"Helicopter", @"Moped", @"Motorcycle",@"Racecar", @"Sailboat", @"Train",@"Truck", @"Tugboat"];
            extension = @"jpg";
        }
        NSString* randomName = beginNames[arc4random()%beginNames.count];
        effectName = [randomName stringByAppendingString: @"Sound"];
        int framesCount = 45;
        NSMutableArray* frames = [NSMutableArray array];
        
        for (int i = 1; i <= framesCount; i++)
        {
            NSString* name = [NSString stringWithFormat: @"%@%04i.%@", randomName, i, extension];
            NSString* filepath = [[NSBundle mainBundle] pathForResource: name ofType: nil];
            UIImage* frame = [UIImage imageWithContentsOfFile: filepath];
            [frames addObject: frame];
        }
        
        if (settingsThemeIndex == 2)
        {
            NSString* bgName = [randomName stringByAppendingFormat: @" background.png"];
            UIImageView* bgView = [[UIImageView alloc] initWithFrame: imageView.frame];
            bgView.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: bgName ofType:nil]];
            [bgView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:duration];
            [self.gameOptionsContainer addSubview: bgView];
        }
        
        UIImageView* animationView = [[UIImageView alloc] initWithFrame: imageView.frame];
        animationView.animationDuration = duration;
        animationView.animationImages = frames;
        animationView.image = frames.lastObject;
        [self.gameOptionsContainer addSubview: animationView];
        [animationView startAnimating];
        [animationView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:duration];
    }
    
    if (settingsCorrectResponseSounds)
    {
        [self playSelectionSound: effectName];
    }
    
    return duration;
}

#pragma mark - Sounds
- (void) playEffect: (NSString*) effectName
{
    NSURL *tickURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: effectName ofType:@"wav"]];
    if (self.effectsPlayer) {
        [self.effectsPlayer stop];
        self.effectsPlayer = nil;
    }
    AVAudioPlayer* tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: tickURL error: nil];
    tickPlayer.delegate = self;
    [tickPlayer prepareToPlay];
    [tickPlayer play];
    self.effectsPlayer = tickPlayer;
}

- (void) playSelectionSound: (NSString*) effectName
{
    NSURL *tickURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: effectName ofType:@"wav"]];
    if (self.selectionPlayer) {
        [self.selectionPlayer stop];
        self.selectionPlayer = nil;
    }
    AVAudioPlayer* tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: tickURL error: nil];
    tickPlayer.delegate = self;
    [tickPlayer prepareToPlay];
    [tickPlayer play];
    self.selectionPlayer = tickPlayer;
}

- (void) playVoSound: (NSString*) filepath
{
    NSURL *tickURL = [NSURL fileURLWithPath: filepath];
    if (self.voPlayer) {
        [self.voPlayer stop];
        self.voPlayer = nil;
    }
    AVAudioPlayer* tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: tickURL error: nil];
    tickPlayer.delegate = self;
    [tickPlayer prepareToPlay];
    [tickPlayer play];
    self.voPlayer = tickPlayer;
    self.gameOptionsContainer.userInteractionEnabled = NO;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(playQuestionForCurrentIndex) object: nil];
    
    if (player == self.voPlayer)
    {
        self.gameOptionsContainer.userInteractionEnabled = YES;
        [self performSelector: @selector(playQuestionForCurrentIndex) withObject: nil afterDelay: ReplayQuestionTimeout];
    }
}

#pragma mark - IBActions

- (IBAction)homePressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated: YES];
}

- (IBAction)playAgainPressed:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(showStatsPrompt) object: nil];
    [self.effectsPlayer stop];
    [missedWords removeAllObjects];
    incorrectGuessCounter = 0;
    
    questionIndex = 0;
    passedQuestions = 0;
    [options shuffle];
    self.butNext.alpha = 1;
    self.txtTopTitle.alpha = 1;
    self.viewResultsPrompt.hidden = YES;
    self.statsContainer.hidden = YES;
    [self layoutOptions];
    [self updateContent];
}

- (IBAction)nextPressed:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(playQuestionForCurrentIndex) object: nil];

    questionIndex ++;
    passedQuestions ++;
    [self layoutOptions];
    [self updateContent];

}

- (IBAction)closeViewResultsPromptPressed:(id)sender
{
    self.viewResultsPrompt.hidden = YES;
}

- (IBAction)viewResultsPressed:(id)sender
{
    self.viewResultsPrompt.hidden = YES;
    self.statsContainer.hidden = NO;
    
    int correctCount = passedQuestions - incorrectGuessCounter;
    int percentage = correctCount*100/passedQuestions;
    self.txtScore.text = [NSString stringWithFormat:@"%i / %i = %i%%", correctCount, passedQuestions, percentage];
	
	NSString *strMiss = @"";
	if (missedWords.count > 0)
		strMiss = missedWords[0];
	
    
	for (int i = 1; i < missedWords.count; i++)
    {
		if (i%2 == 0)
			strMiss = [NSString stringWithFormat:@"%@\r\n%@", strMiss, missedWords[i]];
		else
			strMiss = [NSString stringWithFormat:@"%@    %@", strMiss, missedWords[i]];
	}
	self.txtMissedContent.text = strMiss;
    
}

- (IBAction)closeStatsPressed:(id)sender
{
    self.statsContainer.hidden = YES;
}


#pragma mark - Database

-(void)getImagesfromDB
{
    [options removeAllObjects];
	sqlite3 *database = [appDelegate getDatabase];
	sqlite3_stmt * statements=nil;
	//get default category first
	if (statements == nil) {
		char *sql = "select cateID from setting";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			if(sqlite3_step(statements) == SQLITE_ROW) {
			    categoryID = sqlite3_column_int(statements, 0);
			}
			sqlite3_finalize(statements);
			statements = nil;
		}
	}
	
	if (statements == nil) {
		char *sql = "select id, name,image, audio, selected from image WHERE category=? ORDER BY id ASC";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			sqlite3_bind_int(statements, 1, categoryID);
			sqlite3_bind_int(statements, 2, 1);
			while(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
				CategoryBean *cBean = [[CategoryBean alloc] init];
                cBean.record_ID = sqlite3_column_int(statements, 0);
				if (sqlite3_column_text(statements, 1)) {
					cBean.name = @((char *)sqlite3_column_text(statements, 1));
				}else {
					cBean.name = @"";
				}
				if (sqlite3_column_text(statements, 2)) {
					cBean.image = @((char *)sqlite3_column_text(statements, 2));
				}else {
					cBean.image = @"";
				}
				if (sqlite3_column_text(statements, 3)) {
					cBean.audio = @((char *)sqlite3_column_text(statements, 3));
				}else {
					cBean.audio = @"";
				}
				if (sqlite3_column_int(statements, 4)) {
					cBean.b_Sel = sqlite3_column_int(statements, 4);
				}else {
					cBean.b_Sel = NO;
				}
                
                if (cBean.b_Sel)
                {
                    [options addObject: cBean];
                }
			}
            [options shuffle];
			sqlite3_finalize(statements);
			statements = nil;
		}
	}
}


-(void)getSettings
{
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	if (statements == nil) {
		char *sql = "select turns, advance,qPromote, sounds,visuals, incorrect,visualType from setting";
		
        if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }else{
			//sqlite3_bind_int(statements, 1, categoryID);
			if(sqlite3_step(statements) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				
                settingsNumberOfTurns = sqlite3_column_int(statements, 0);
				settingsPracticeMode = sqlite3_column_int(statements, 1);
				settingsQuestionPrompt = sqlite3_column_int(statements, 2);
                settingsCorrectResponseSounds = sqlite3_column_int(statements, 3);
                settingsCorrectResponseVisual = sqlite3_column_int(statements, 4);
				settingsIncorrectResponse = sqlite3_column_int(statements, 5);
				settingsThemeIndex = sqlite3_column_int(statements, 6);
			}
			sqlite3_finalize(statements);
		}
	}
}


//get folder name and category name by ID
-(void)getNames: (int)category name:(NSMutableArray *)arrayName
{
	GameAppDelegate *app = (GameAppDelegate *)[[UIApplication sharedApplication] delegate];
	sqlite3 *database = [app getDatabase];
	sqlite3_stmt * statements=nil;
	
	//get category name
	int _parentID = 0;
	char *sql = "select name,parentId from category WHERE id=?";
	if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}else{
		sqlite3_bind_int(statements, 1, categoryID);
		if(sqlite3_step(statements) == SQLITE_ROW) {
			if (sqlite3_column_text(statements, 0)) {
				[arrayName addObject:@((char *)sqlite3_column_text(statements, 0))];
			}else {
				[arrayName addObject:@""];
			}
			_parentID = sqlite3_column_int(statements, 1);
		}
		sqlite3_finalize(statements);
		statements = nil;
	}
	
	//get folder name
	sql = "select name from category WHERE id=?";
	
	if (sqlite3_prepare_v2(database, sql, -1, &statements, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}else{
		sqlite3_bind_int(statements, 1, _parentID);
		if(sqlite3_step(statements) == SQLITE_ROW) {
			if (sqlite3_column_text(statements, 0)) {
				[arrayName addObject:@((char *)sqlite3_column_text(statements, 0))];
			}else {
				[arrayName addObject:@""];
			}
		}
		sqlite3_finalize(statements);
		statements = nil;
	}
}


- (void) storeResultToDB
{
	sqlite3 *db = [appDelegate getDatabase];
	
    
    int correctCount = passedQuestions - incorrectGuessCounter;
	
	NSString *strMiss = @"";
	if (missedWords.count > 0)
		strMiss = missedWords[0];
	
	for (int i = 1; i < missedWords.count; i++)
    {
		if (i%2 == 0)
			strMiss = [NSString stringWithFormat:@"%@\r\n%@", strMiss, missedWords[i]];
		else
			strMiss = [NSString stringWithFormat:@"%@    %@", strMiss, missedWords[i]];
	}

	
	// get current date/time
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	// display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	//[dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm"];
	NSString *currentTime = [dateFormatter stringFromDate:today];
	//NSLog(@"%@", currentTime);
	
	NSMutableArray *array_Names = [[NSMutableArray alloc] init];
	[self getNames:categoryID name:array_Names];
	
	sqlite3_stmt * statements=nil;
	if (statements == nil) {// in
		static char *sql = "INSERT INTO score(time, score, right, total, folder, category) VALUES(?, ?, ?, ?, ?,?)";
		if (sqlite3_prepare_v2(db, sql, -1, &statements, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(statements, 1, [currentTime UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statements, 2, [strMiss UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statements, 3, correctCount);
		sqlite3_bind_int(statements, 4, passedQuestions);
		sqlite3_bind_text(statements, 5, [array_Names[0] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statements, 6, [array_Names[1] UTF8String], -1, SQLITE_TRANSIENT);
		
		int success = sqlite3_step(statements);
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
		}
		// All data for the book is already in memory, but has not be written to the database
		sqlite3_finalize(statements);
		statements = nil;
	}
	

}

#pragma mark - Win

- (void) animateWin
{
    if (dismissed)
    {
        return;
    }
    if (!settingsPracticeMode && ![SharedObjects objects].isColorSlapps)
    {
        [self storeResultToDB];
    }
    
    if (self.voPlayer)
    {
        self.voPlayer.delegate = nil;
        [self.voPlayer stop];
        self.voPlayer = nil;
    }
    self.gameOptionsContainer.alpha = 0;
    self.winAnimation.alpha = 1;
    self.butNext.alpha = 0;
    self.txtTopTitle.alpha = 0;
    NSMutableArray* frames = [NSMutableArray array];
    
    int framesCount;
    int animationRepeatCount = 0;
    float animationDuration = 0;
    float animationDurationExtended = 0;
    NSString* framesBasename = nil;
    NSString* winSound = nil;
    switch (settingsThemeIndex) {
        case 0: {
            framesBasename = @"kids_jumping";
            framesCount = 42;
            winSound = @"Cheer_Children";
            animationDuration = 1.5;
            
            self.butPlayAgain.transform = CGAffineTransformMakeTranslation(0, 500);
            [UIView animateWithDuration: 1.0
                                  delay: animationDuration
                                options: 0
                             animations: ^{
                                 self.butPlayAgain.transform = CGAffineTransformIdentity;
                             } completion:^(BOOL finished) {
                             }];

            break;
        }
        case 1: {
            framesBasename = @"Rocket";
            framesCount = 3;
            winSound = @"rocket 5 seconds";
            animationDuration = 1;
            animationDurationExtended = 5.0;
            animationRepeatCount = 5;
            
            self.winAnimation.transform = CGAffineTransformMakeTranslation(0, 150);
            [UIView animateWithDuration: animationDurationExtended
                                  delay: 0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations: ^{
                                 self.winAnimation.transform = CGAffineTransformMakeTranslation(0, -600);
                             } completion:^(BOOL finished) {
                                 self.winAnimation.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"words-rocket" ofType:@"png"]];
                                 self.winAnimation.transform = CGAffineTransformIdentity;
                                 self.butPlayAgain.alpha = 1;
                             }];
            break;
        }
        case 2:
            framesBasename = @"Tractor";
            framesCount = 3;
            winSound = @"tractor sound 5 secondsl";
            animationDuration = 0.5;
            animationDurationExtended = 5.0;
            animationRepeatCount = 10;
            self.winAnimation.transform = CGAffineTransformMakeTranslation(850, 100);
            [UIView animateWithDuration: animationDurationExtended
                                  delay: 0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations: ^{
                                 self.winAnimation.transform = CGAffineTransformMakeTranslation(-1000, 100);
                             } completion:^(BOOL finished) {
                                 self.winAnimation.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Words-tractor" ofType:@"png"]];
                                 self.winAnimation.transform = CGAffineTransformIdentity;
                                 self.butPlayAgain.alpha = 1;
                             }];
            break;
    }
    for (int i = 1; i <= framesCount; i++)
    {
        NSString* name = [NSString stringWithFormat: @"%@%04i.png",framesBasename,i];
        NSString* filepath = [[NSBundle mainBundle] pathForResource: name ofType: nil];
        UIImage* aFrame = [UIImage imageWithContentsOfFile: filepath];
        [frames addObject: aFrame];
    }
    self.winAnimation.animationImages = frames;
    self.winAnimation.animationDuration = animationDuration;
    self.winAnimation.animationRepeatCount = animationRepeatCount;
    [self.winAnimation startAnimating];
    
    [self playEffect: winSound];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, animationDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^
    {
        if (settingsThemeIndex == 0)
        {
            self.butPlayAgain.alpha = 1;
        }
        if (!settingsPracticeMode)
        {
            [self performSelector: @selector(showStatsPrompt) withObject:nil afterDelay: 2 + animationDurationExtended];
        }
    });

}


- (void) showStatsPrompt
{
    self.viewResultsPrompt.hidden = NO;
}



- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    if (self.voPlayer)
    {
        self.voPlayer.delegate = nil;
        [self.voPlayer stop];
    }
    if (self.effectsPlayer)
    {
        self.effectsPlayer.delegate = nil;
        [self.effectsPlayer stop];
    }
    if (self.selectionPlayer)
    {
        self.selectionPlayer.delegate = nil;
        [self.selectionPlayer stop];
    }
}

- (void)viewDidUnload {
    [self setGameOptionsContainer:nil];
    [self setTxtTopTitle:nil];
    [self setIncorrectAnswerX:nil];
    [self setWinAnimation:nil];
    [self setButPlayAgain:nil];
    bgMain = nil;
    [self setButNext:nil];
    [self setViewResultsPrompt:nil];
    [self setStatsContainer:nil];
    [self setTxtWordsMissed:nil];
    [self setTxtMissedContent:nil];
    [self setTxtScore:nil];
    [super viewDidUnload];
}



@end
