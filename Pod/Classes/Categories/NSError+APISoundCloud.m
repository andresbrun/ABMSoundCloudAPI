//
//  NSError+APISoundCloud.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun on 08/03/15.
//  Copyright (c) 2015 Brun's Software. All rights reserved.
//

#import "NSError+APISoundCloud.h"

@implementation NSError (APISoundCloud)

+ (NSError *)createParsingError {
    return [NSError errorWithDomain:@"APIManager" code:490 userInfo:@{@"Info":@"Parse error."}];
}

+ (NSError *)createNonStreamableSongError {
    return [NSError errorWithDomain:@"APIManager" code:480 userInfo:@{@"Info":@"The song is not streamable."}];
}

+ (NSError *)createConnexionError {
    return [NSError errorWithDomain:@"APIManager" code:600 userInfo:@{@"Info":@"No connection."}];
}

+ (NSError *)createSessionError {
    return [NSError errorWithDomain:@"APIManager" code:401 userInfo:@{@"Info":@"No Session."}];
}

@end
