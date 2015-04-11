//
//  ABMAuth2Manager.m
//  Pods
//
//  Created by Benjamin Maer on 4/6/15.
//
//

#import "ABMAuth2Manager.h"





NSString * const kABMAuth2Manager_AuthCodeGrantType = @"authorization_code";





typedef NS_ENUM(NSInteger, ABMAuth2Manager_HTTPMethodType) {
	ABMAuth2Manager_HTTPMethodType_GET,
	ABMAuth2Manager_HTTPMethodType_POST,
};

static NSString * const kAMBCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * AMBPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
	static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
	
	return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kAMBCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}




@interface ABMAuth2Manager ()

@property (nonatomic, readonly) NSURLSession* session;

- (NSURLSessionDataTask *)URLSessionDataTaskWithRequest:(NSURLRequest*)URLRequest
												success:(abm_Auth2Manager_successBlock)success
												failure:(abm_Auth2Manager_failureBlock)failure;

-(void)applyParameters:(id)parameters toHTTPBodyOfRequest:(NSMutableURLRequest*)URLRequest;
-(NSString*)URLStringWithParameters:(id)parameters withBaseURLString:(NSString*)URLString;
-(NSURL*)URLWithString:(NSString*)URLString parameters:(id)parameters HTTPMethodType:(ABMAuth2Manager_HTTPMethodType)HTTPMethodType;

- (NSMutableURLRequest *)URLRequestURLString:(NSString*)URLString
								  parameters:(id)parameters
							  HTTPMethodType:(ABMAuth2Manager_HTTPMethodType)HTTPMethodType;

+(NSString*)requestHTTPMethodForType:(ABMAuth2Manager_HTTPMethodType)HTTPMethodType;

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
		 @{@"Accept"			: @"application/json",
		   }
		 ];

		[sessionConfig setTimeoutIntervalForRequest:30.0f];
		[sessionConfig setTimeoutIntervalForResource:60.0f];
		[sessionConfig setHTTPMaximumConnectionsPerHost:1];

//		NSAssert((self.session.configuration == sessionConfig), @"unhandled");
		_session = [NSURLSession sessionWithConfiguration:sessionConfig];
	}
	
	return self;
}

#pragma mark - Authenticate
- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
														 code:(NSString *)code
												  redirectURI:(NSString *)uri
													  success:(abm_Auth2Manager_successBlock)success
													  failure:(abm_Auth2Manager_failureBlock)failure
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
	
//	NSString* encodedURI = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString* encodedURI = AMBPercentEscapedQueryStringKeyFromStringWithEncoding(uri, NSUTF8StringEncoding);

	NSDictionary *parameters =
 @{
   @"grant_type"	: kABMAuth2Manager_AuthCodeGrantType,
   @"code"			: code,
   @"redirect_uri"	: encodedURI
   };

	return [self authenticateUsingOAuthWithURLString:URLString parameters:parameters addAuthenticationParams:YES success:success failure:failure];
}

//@TODO maybe get rid of addAuthenticationParams if it ends up used the same everywhere.
- (NSURLSessionDataTask *)authenticateUsingOAuthWithURLString:(NSString *)URLString
												   parameters:(NSDictionary *)parameters
									  addAuthenticationParams:(BOOL)addAuthenticationParams
													  success:(abm_Auth2Manager_successBlock)success
													  failure:(abm_Auth2Manager_failureBlock)failure
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

	return [self POST:URLString parameters:parameters success:success failure:failure];
//	NSURLSessionDataTask* URLSessionDataTask = [self.session dataTaskWithURL:[NSURL URLWithString:URLString relativeToURL:self.baseURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//
//		if (error ||
//			(response == nil) ||
//			(data == nil))
//		{
//			failureCheckBlock(error);
//			return;
//		}
//
//		NSError* jsonParseError = nil;
//		NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
//
//		if (jsonParseError)
//		{
//			failureCheckBlock(jsonParseError);
//			return;
//		}
//
//		if (success)
//		{
//			success(jsonData);
//		}
//
//	}];
//
//	[URLSessionDataTask resume];
//	return URLSessionDataTask;
//
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

#pragma mark - Requests
- (NSURLSessionDataTask *)URLSessionDataTaskWithRequest:(NSURLRequest*)URLRequest
												success:(abm_Auth2Manager_successBlock)success
												failure:(abm_Auth2Manager_failureBlock)failure
{
	if (self.session == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	if (URLRequest == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	void (^failureCheckBlock)(NSError* error) = ^(NSError* error){
		if (failure)
		{
			failure(error);
		}
	};

	NSURLSessionDataTask* URLSessionDataTask = [self.session dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
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
}

-(void)applyParameters:(id)parameters toHTTPBodyOfRequest:(NSMutableURLRequest*)URLRequest
{
	NSError* jsonError = nil;
	NSString* parametersString = [self URLStringWithParameters:parameters withBaseURLString:nil];
	NSData* parameterData = [parametersString dataUsingEncoding:NSUTF8StringEncoding];
//	NSData* parameterData = [NSJSONSerialization dataWithJSONObject:parametersString options:0 error:&jsonError];
	
	if (jsonError)
	{
		NSAssert(false, @"unhandled");
		return;
	}
	
	[URLRequest setHTTPBody:parameterData];
}

-(NSString*)URLStringWithParameters:(id)parameters withBaseURLString:(NSString*)URLString
{
	NSMutableString* mutableURLString = (URLString ? [URLString mutableCopy] : [NSMutableString string]);

	if (parameters)
	{
		if ([parameters isKindOfClass:[NSDictionary class]])
		{
			NSDictionary* parametersDictionary = parameters;
			[parametersDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				
				if (mutableURLString.length)
				{
					[mutableURLString appendString:@"&"];
				}

				[mutableURLString appendFormat:@"%@=%@",key,obj];

			}];
		}
		else
		{
			NSAssert(false, @"unhandled");
		}
	}

	return mutableURLString;
}

-(NSURL*)URLWithString:(NSString*)URLString parameters:(id)parameters HTTPMethodType:(ABMAuth2Manager_HTTPMethodType)HTTPMethodType
{
	if (parameters)
	{
		switch (HTTPMethodType)
		{
			case ABMAuth2Manager_HTTPMethodType_GET:
				URLString = [self URLStringWithParameters:parameters withBaseURLString:URLString];
				break;
				
			case ABMAuth2Manager_HTTPMethodType_POST:
				break;
		}
	}

	return [NSURL URLWithString:URLString relativeToURL:self.baseURL];
}

- (NSMutableURLRequest *)URLRequestURLString:(NSString*)URLString
								  parameters:(id)parameters
							  HTTPMethodType:(ABMAuth2Manager_HTTPMethodType)HTTPMethodType
{
	if (URLString.length == 0)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	NSURL *URL = [self URLWithString:URLString parameters:parameters HTTPMethodType:HTTPMethodType];
	if (URL == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}
	
	NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:URL];
	[mutableURLRequest setHTTPMethod:[[self class]requestHTTPMethodForType:HTTPMethodType]];

	if (parameters)
	{
		switch (HTTPMethodType)
		{
			case ABMAuth2Manager_HTTPMethodType_POST:
				[self applyParameters:parameters toHTTPBodyOfRequest:mutableURLRequest];
				[mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
				break;

			case ABMAuth2Manager_HTTPMethodType_GET:
				[mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
				break;
		}
	}

	[self.session.configuration.HTTPAdditionalHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[mutableURLRequest setValue:obj forHTTPHeaderField:key];
	}];

	return mutableURLRequest;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
					parameters:(id)parameters
					   success:(abm_Auth2Manager_successBlock)success
					   failure:(abm_Auth2Manager_failureBlock)failure
{
	NSMutableURLRequest *request = [self URLRequestURLString:URLString parameters:parameters HTTPMethodType:ABMAuth2Manager_HTTPMethodType_POST];
	if (request == nil)
	{
		NSAssert(false, @"unhandled");
		return nil;
	}

	return [self URLSessionDataTaskWithRequest:request success:success failure:failure];
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

+(NSString*)requestHTTPMethodForType:(ABMAuth2Manager_HTTPMethodType)HTTPMethodType
{
	switch (HTTPMethodType)
	{
		case ABMAuth2Manager_HTTPMethodType_GET:
			return @"GET";

		case ABMAuth2Manager_HTTPMethodType_POST:
			return @"POST";
	}

	NSAssert(false, @"unhandled");
	return nil;
}

@end
