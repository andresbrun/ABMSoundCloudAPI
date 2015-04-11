//
//  ABMSoundCloudAPISingleton.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMSoundCloudAPISingleton.h"

@interface ABMSoundCloudAPISingleton ()
@property (nonatomic, strong) ABMSoundCloudPort *soundCloudPort;
@end

@implementation ABMSoundCloudAPISingleton

+ (instancetype)sharedManager
{
    static ABMSoundCloudAPISingleton *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) setClientID:(NSString *)clientID secretKey:(NSString *)secretKey {
    self.soundCloudPort = [[ABMSoundCloudPort alloc] initWithClientId:clientID clientSecret:secretKey];
}

@end
