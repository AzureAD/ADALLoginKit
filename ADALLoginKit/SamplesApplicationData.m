#import "SamplesApplicationData.h"

@implementation SamplesApplicationData

+(id) getInstance
{
    static SamplesApplicationData *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info" ofType:@"plist"]];
        instance.clientId = [dictionary objectForKey:@"microsoftClientId"];
        instance.redirectUriString = [dictionary objectForKey:@"microsoftRedirectUri"];
        instance.authority = @"https://login.microsoftonline.com/common";
        instance.resourceId = @"https://graph.windows.net";


        
    });
    
    return instance;
}

@end
