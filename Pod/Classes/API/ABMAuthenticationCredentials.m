//
//  ABMAuthenticationCredentials.m
//  Pods
//
//  Created by Benjamin Maer on 4/11/15.
//
//

#import "ABMAuthenticationCredentials.h"





@interface ABMAuthenticationCredentials ()

@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic, copy) NSString *tokenType;

@end





@implementation ABMAuthenticationCredentials

#pragma mark - Contructor
+ (instancetype)credentialWithOAuthToken:(NSString *)token
							   tokenType:(NSString *)type
{
	return [[self alloc] initWithOAuthToken:token tokenType:type];
}

- (id)initWithOAuthToken:(NSString *)token
			   tokenType:(NSString *)type
{
	if (self = [super init])
	{
		[self setAccessToken:token];
		[self setTokenType:type];
	}
	
	return self;
}

#pragma mark - Expired
- (BOOL)isExpired {
	return [self.expiration compare:[NSDate date]] == NSOrderedAscending;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	self.accessToken = [decoder decodeObjectForKey:NSStringFromSelector(@selector(accessToken))];
	self.tokenType = [decoder decodeObjectForKey:NSStringFromSelector(@selector(tokenType))];
	self.refreshToken = [decoder decodeObjectForKey:NSStringFromSelector(@selector(refreshToken))];
	self.expiration = [decoder decodeObjectForKey:NSStringFromSelector(@selector(expiration))];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
	[encoder encodeObject:self.tokenType forKey:NSStringFromSelector(@selector(tokenType))];
	[encoder encodeObject:self.refreshToken forKey:NSStringFromSelector(@selector(refreshToken))];
	[encoder encodeObject:self.expiration forKey:NSStringFromSelector(@selector(expiration))];
}

@end
