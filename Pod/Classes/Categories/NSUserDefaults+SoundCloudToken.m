//
//  NSUserDefaults+soundCloudToken.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 05/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import "NSUserDefaults+SoundCloudToken.h"

NSString *kSCTokenKey = @"sc_key_token";

@implementation NSUserDefaults (SoundCloudToken)

+ (void)saveSoundCloudToken:(NSString *)token {
    [[self standardUserDefaults] setObject:token forKey:kSCTokenKey];
    [[self standardUserDefaults] synchronize];
}

+ (NSString *)getSoundCloudCode {
    return [[self standardUserDefaults] objectForKey:kSCTokenKey];
}

+ (void)removeSoundCloudCode {
    [[self standardUserDefaults] removeObjectForKey:kSCTokenKey];
    [[self standardUserDefaults] synchronize];
}

@end
