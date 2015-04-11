//
//  ABMSoundCloudAPISingleton.h
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ABMSoundCloudAPI/ABMSoundCloudPort.h>

@interface ABMSoundCloudAPISingleton : NSObject

+ (instancetype)sharedManager;

- (void) setClientID:(NSString *)clientID secretKey:(NSString *)secretKey;

@property (nonatomic, readonly) ABMSoundCloudPort *soundCloudPort;

@end
