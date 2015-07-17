//
//  RSA.h
//  SimpleRSA
//
//  Created by Zhenwang Zha on 15/7/13.
//  Copyright (c) 2015年 zhenwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSA : NSObject

- (NSString *)encryptRSA:(NSString *)plainText;

- (NSString *)decryptRSA:(NSString *)plainText;

@end
