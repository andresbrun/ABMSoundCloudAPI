//
//  ABMAuthenticationCredentials.m
//  Pods
//
//  Created by Benjamin Maer on 4/11/15.
//
//

#import "RUAuthenticationCredentials.h"

#import <Security/Security.h>





static NSString * const kABMOAuth2CredentialServiceName = @"kABMOAuth2CredentialService";





static NSDictionary * ABMKeychainQueryDictionaryWithIdentifier(NSString *identifier) {
	NSCParameterAssert(identifier);
	
	return @{
			 (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
			 (__bridge id)kSecAttrService: kABMOAuth2CredentialServiceName,
			 (__bridge id)kSecAttrAccount: identifier
    };
}





@interface RUAuthenticationCredentials ()

@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic, copy) NSString *tokenType;

+ (BOOL)storeCredential:(RUAuthenticationCredentials *)credential
		 withIdentifier:(NSString *)identifier
	  withAccessibility:(id)securityAccessibility;

@end





@implementation RUAuthenticationCredentials

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

#pragma mark - Storing
+ (BOOL)storeCredential:(RUAuthenticationCredentials*)credential
		 withIdentifier:(NSString *)identifier
{
	id securityAccessibility = nil;
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 43000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)
	if (&kSecAttrAccessibleWhenUnlocked) {
		securityAccessibility = (__bridge id)kSecAttrAccessibleWhenUnlocked;
	}
#endif
	
	return [[self class] storeCredential:credential withIdentifier:identifier withAccessibility:securityAccessibility];
}

+ (BOOL)storeCredential:(RUAuthenticationCredentials *)credential
		 withIdentifier:(NSString *)identifier
	  withAccessibility:(id)securityAccessibility
{
	NSMutableDictionary *queryDictionary = [ABMKeychainQueryDictionaryWithIdentifier(identifier) mutableCopy];
	
	if (!credential) {
		return [self deleteCredentialWithIdentifier:identifier];
	}
	
	NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
	updateDictionary[(__bridge id)kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:credential];
	
	if (securityAccessibility) {
		updateDictionary[(__bridge id)kSecAttrAccessible] = securityAccessibility;
	}
	
	OSStatus status;
	BOOL exists = ([self retrieveCredentialWithIdentifier:identifier] != nil);
	
	if (exists) {
		status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
	} else {
		[queryDictionary addEntriesFromDictionary:updateDictionary];
		status = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL);
	}
	
	if (status != errSecSuccess) {
		NSLog(@"Unable to %@ credential with identifier \"%@\" (Error %li)", exists ? @"update" : @"add", identifier, (long int)status);
	}
	
	return (status == errSecSuccess);
}

+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier
{
	NSMutableDictionary *queryDictionary = [ABMKeychainQueryDictionaryWithIdentifier(identifier) mutableCopy];
	
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
	
	if (status != errSecSuccess) {
		NSLog(@"Unable to delete credential with identifier \"%@\" (Error %li)", identifier, (long int)status);
	}
	
	return (status == errSecSuccess);
}

+ (RUAuthenticationCredentials *)retrieveCredentialWithIdentifier:(NSString *)identifier
{
	NSMutableDictionary *queryDictionary = [ABMKeychainQueryDictionaryWithIdentifier(identifier) mutableCopy];
	queryDictionary[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
	queryDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
	
	CFDataRef result = nil;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&result);
	
	if (status != errSecSuccess) {
		NSLog(@"Unable to fetch credential with identifier \"%@\" (Error %li)", identifier, (long int)status);
		return nil;
	}
	
	return [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)result];
}

@end
