//
//  ADALLoginButton.h
//  ADALLoginKit
//
//  Created by Brandon Werner on 7/6/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

@protocol ADALLoginButtonDelegate;

@interface ADALLoginButton : ADALButton

/*!
 @abstract Gets or sets the delegate.
 */
@property (weak, nonatomic) IBOutlet id<ADALLoginButtonDelegate> delegate;
/*!
 @abstract Gets or sets the login behavior to use
 */
@property (assign, nonatomic) ADALLoginBehavior* loginBehavior;

@end

/*!
 @protocol
 @abstract A delegate for `ADALLoginButton`
 */
@protocol ADALLoginButtonDelegate <NSObject>

@required
/*!
 @abstract Sent to the delegate when the button was used to login.
 @param loginButton the sender
 @param result The results of the login
 @param error The error (if any) from the login
 */
- (void)  loginButton:(ADALLoginButton *)loginButton
didCompleteWithResult:(ADALLoginManagerLoginResult *)result
                error:(NSError *)error;

/*!
 @abstract Sent to the delegate when the button was used to logout.
 @param loginButton The button that was clicked.
 */
- (void)loginButtonDidLogOut:(ADALLoginButton *)loginButton;

@optional
/*!
 @abstract Sent to the delegate when the button is about to login.
 @param loginButton the sender
 @return YES if the login should be allowed to proceed, NO otherwise
 */
- (BOOL) loginButtonWillLogin:(ADALLoginButton *)loginButton;

@end


