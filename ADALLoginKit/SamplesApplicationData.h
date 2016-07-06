//
//  SamplesApplicationData.h
//  ADALLoginKit
//
//  Created by Brandon Werner on 7/6/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SamplesApplicationData : NSObject

@property (strong) NSString* taskWebApiUrlString;
@property (strong) NSString* authority;
@property (strong) NSString* clientId;
@property (strong) NSString* resourceId;
@property (strong) NSString* redirectUriString;
@property (strong) NSString* correlationId;
@property BOOL fullScreen;
@property BOOL showClaims;

+(id) getInstance;


@end
