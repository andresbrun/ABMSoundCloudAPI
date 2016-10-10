//
//  SoundCloudLoginWebViewController.h
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 08/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundCloudLoginWebViewController: UIViewController

+ (nonnull UINavigationController *)instantiateWithLoginURL:(nonnull NSString *)loginURL
                                                redirectURL:(nonnull NSString *)redirectURL
                                                resultBlock:(void (^)(BOOL result, NSString *code))resultBlock;

@property (strong, nonatomic, nonnull) NSString *scLoginURL;
@property (strong, nonatomic, nonnull) NSString *redirectURL;
@property (copy, nonatomic) void (^resultBlock)(BOOL success,  NSString * _Nullable code);

@end
