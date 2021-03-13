#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


static const NSInteger LiteVersionMaxLevels = 3;
static const NSInteger LiteVersionMaxFolders = 1;
static const NSInteger LiteVersionMaxCategories = 2;
static const NSInteger LiteVersionMaxImagesInCategory = 8;

@interface SharedObjects : NSObject <AVAudioPlayerDelegate> {
}

+ (SharedObjects*) objects;

@property (nonatomic, assign) BOOL isPro;
@property (nonatomic, assign) BOOL isColorSlapps;

@end
