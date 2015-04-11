//
//  ABMAuth2Manager.m
//  Pods
//
//  Created by Benjamin Maer on 4/6/15.
//
//

#import "ABMAuth2Manager.h"





NSString * const kABMAuth2Manager_AuthCodeGrantType = @"authorization_code";





@interface ABMAuth2Manager ()

@property (nonatomic, readonly) NSURLSession* session;

@end





@implementation ABMAuth2Manager

#pragma mark - NSObject
-(instancetype)init
{
	if (self = [super init])
	{
		NSURLSessionConfiguration *sessionConfig =
		[NSURLSessionConfiguration defaultSessionConfiguration];
		
		// Here you restrict network operations to wifi only.
//		sessionConfig.allowsCellularAccess = NO;
		
		// This will set all requests to only accept JSON responses.
		[sessionConfig setHTTPAdditionalHeaders:
		 @{@"Accept": @"application/json"}];

		[sessionConfig setTimeoutIntervalForRequest:30.0f];
		[sessionConfig setTimeoutIntervalForResource:60.0f];
		[sessionConfig setHTTPMaximumConnectionsPerHost:1];

//		NSAssert((self.session.configuration == sessionConfig), @"unhandled");
		_session = [NSURLSession sessionWithConfiguration:sessionConfig];
	}
	
	return self;
}

//#pragma mark - session
//-(NSURLSession *)session
//{
//	return [NSURLSession sharedSession];
//}

#pragma mark - Authenticate
- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
														 code:(NSString *)code
												  redirectURI:(NSString *)uri
													  success:(void (^)(NSDictionary *jsonResponse))success
													  failure:(void (^)(NSError *error))failure
{
	if (URLString.length == 0)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	if (code == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	if (uri == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	NSParameterAssert(code);
	NSParameterAssert(uri);
	
	NSDictionary *parameters =
 @{
   @"grant_type": kABMAuth2Manager_AuthCodeGrantType,
   @"code": code,
   @"redirect_uri": uri
   };

	return [self authenticateUsingOAuthWithURLString:URLString parameters:parameters addAuthenticationParams:YES success:success failure:failure];
}

//@TODO maybe get rid of addAuthenticationParams if it ends up used the same everywhere.
- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
													 parameters:(NSDictionary *)parameters
										addAuthenticationParams:(BOOL)addAuthenticationParams
														success:(void (^)(NSDictionary *jsonResponse))success
														failure:(void (^)(NSError *error))failure
{
	if (self.baseURL == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	if (self.session == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	NSMutableDictionary *mutableParameters = [parameters mutableCopy];
	if (addAuthenticationParams)
	{
		if (self.clientId)
		{
			[mutableParameters setObject:self.clientId forKey:@"client_id"];
		}

		if (self.secret)
		{
			[mutableParameters setObject:self.secret forKey:@"client_secret"];
		}
	}
	parameters = [mutableParameters copy];

	void (^failureCheckBlock)(NSError* error) = ^(NSError* error){
		if (failure)
		{
			failure(error);
		}
	};
	NSURLSessionDataTask* URLSessionDataTask = [self.session dataTaskWithURL:[NSURL URLWithString:URLString relativeToURL:self.baseURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

		if (error ||
			(response == nil) ||
			(data == nil))
		{
			failureCheckBlock(error);
			return;
		}

		NSError* jsonParseError = nil;
		NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];

		if (jsonParseError)
		{
			failureCheckBlock(jsonParseError);
			return;
		}

		if (success)
		{
			success(jsonData);
		}

	}];

	[URLSessionDataTask resume];
	return URLSessionDataTask;

//	AFHTTPRequestOperation *requestOperation = [self POST:URLString parameters:parameters success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
//		if (!responseObject) {
//			if (failure) {
//				failure(nil);
//			}
//			
//			return;
//		}
//		
//		if ([responseObject valueForKey:@"error"]) {
//			if (failure) {
//				failure(AFErrorFromRFC6749Section5_2Error(responseObject));
//			}
//			
//			return;
//		}
//		
//		NSString *refreshToken = [responseObject valueForKey:@"refresh_token"];
//		if (!refreshToken || [refreshToken isEqual:[NSNull null]]) {
//			refreshToken = [parameters valueForKey:@"refresh_token"];
//		}
//		
//		AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:[responseObject valueForKey:@"access_token"] tokenType:[responseObject valueForKey:@"token_type"]];
//		
//		
//		if (refreshToken) { // refreshToken is optional in the OAuth2 spec
//			[credential setRefreshToken:refreshToken];
//		}
//		
//		// Expiration is optional, but recommended in the OAuth2 spec. It not provide, assume distantFuture === never expires
//		NSDate *expireDate = [NSDate distantFuture];
//		id expiresIn = [responseObject valueForKey:@"expires_in"];
//		if (expiresIn && ![expiresIn isEqual:[NSNull null]]) {
//			expireDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
//		}
//		
//		if (expireDate) {
//			[credential setExpiration:expireDate];
//		}
//		
//		if (success) {
//			success(credential);
//		}
//	} failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure(error);
//		}
//	}];
//	
//	return requestOperation;
}

//#pragma mark - Singleton
//+(ABMAuth2Manager*)abm_sharedAuth2Manager
//{
//	static ABMAuth2Manager* abm_sharedAuth2Manager;
//	@synchronized (self)
//	{
//		static dispatch_once_t onceToken;
//		dispatch_once(&onceToken, ^{
//			abm_sharedAuth2Manager = [ABMAuth2Manager new];
//		});
//	}
//	return abm_sharedAuth2Manager;
//}

@end
