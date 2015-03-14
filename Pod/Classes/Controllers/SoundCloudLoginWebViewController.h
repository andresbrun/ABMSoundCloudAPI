//
//  SoundCloudLoginWebViewController.h
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 08/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundCloudLoginWebViewController : UIViewController

+ (UINavigationController *)instantiateWithLoginURL:(NSString *)loginURL resultBlock:(void (^)(BOOL result, NSString *code))resultBlock;

@property (strong, nonatomic) NSString *scLoginURL;
@property (copy, nonatomic) void (^resultBlock)(BOOL success, NSString *code);

@end
