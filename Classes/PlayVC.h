//
//  PlayVC.h
//  Game
//
//  Created by Alexey Kuchmiy on 31.03.13.
//
//

#import "CommonVC.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayVC : CommonVC <AVAudioPlayerDelegate>
{
    int passedQuestions;
    int incorrectGuessCounter;
    int questionIndex;
    int categoryID;
    int correctAnswerTag;
    int settingsThemeIndex;
    
    
	int settingsNumberOfTurns;
	BOOL settingsPracticeMode;
	BOOL settingsQuestionPrompt;
	BOOL settingsCorrectResponseSounds;
	BOOL settingsCorrectResponseVisual;
	BOOL settingsIncorrectResponse;

    NSMutableArray* options;
    NSMutableArray* missedWords;
    IBOutlet UIImageView *bgMain;
    
    BOOL dismissed;
}
@property (strong, nonatomic) IBOutlet UIButton *butNext;
@property (strong, nonatomic) IBOutlet UIButton *butPlayAgain;
@property (strong, nonatomic) IBOutlet UIImageView *winAnimation;
@property (strong, nonatomic) IBOutlet UIImageView *incorrectAnswerX;
@property (nonatomic, assign) int level;
@property (strong, nonatomic) AVAudioPlayer* selectionPlayer;
@property (strong, nonatomic) AVAudioPlayer* voPlayer;
@property (strong, nonatomic) AVAudioPlayer* effectsPlayer;
@property (strong, nonatomic) IBOutlet UIView *gameOptionsContainer;
@property (strong, nonatomic) IBOutlet UILabel *txtTopTitle;
@property (strong, nonatomic) IBOutlet UIView *viewResultsPrompt;
@property (strong, nonatomic) IBOutlet UIView *statsContainer;
@property (strong, nonatomic) IBOutlet UILabel *txtWordsMissed;
@property (strong, nonatomic) IBOutlet UITextView *txtMissedContent;
@property (strong, nonatomic) IBOutlet UILabel *txtScore;
@property (strong, nonatomic) NSString* curGuessWordTitle;
- (IBAction)optionDidPress:(id)sender;
- (IBAction)homePressed:(id)sender;
- (IBAction)playAgainPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;
- (IBAction)closeViewResultsPromptPressed:(id)sender;
- (IBAction)viewResultsPressed:(id)sender;
- (IBAction)closeStatsPressed:(id)sender;

@end
