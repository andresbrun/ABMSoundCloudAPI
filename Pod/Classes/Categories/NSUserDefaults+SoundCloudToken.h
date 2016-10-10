//
//  NSUserDefaults+soundCloudToken.h
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 05/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (SoundCloudToken)

+ (void)saveSoundCloudToken:(nonnull NSString *)token;
+ (nullable NSString *)getSoundCloudCode;
+ (void)removeSoundCloudCode;

@end
