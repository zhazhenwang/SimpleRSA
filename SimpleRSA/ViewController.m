//
//  ViewController.m
//  SimpleRSA
//
//  Created by Zhenwang Zha on 15/7/17.
//  Copyright (c) 2015年 zhenwang. All rights reserved.
//

#import "ViewController.h"
#import "RSA.h"

static NSString * const plainText = @"Hello RSA encrypt!";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    RSA * rsa = [RSA new];
    
    NSLog(@"加密后 == %@", [rsa encryptRSA:plainText]);
    
    NSLog(@"解密后 == %@", [rsa decryptRSA:@"epOQGDP5YDAv2csqSbSLJ+/eVwL3nkxJlmmGRYM5yEMLq/jhIfMhTnr3286QDqr/he3WKAVgdPpspABr0K+G3RzYwGmvFRMKk3RPJJ10uVDlr01kIP1j6SUiHIpyCLejRkdZumvke2urkgeqkkaVlBbKinOCSoFiYy19MaPnqjI="]);
    
    [rsa release];
}

@end

/*
 
 附上: 私钥 .pem -> .p12 步骤
 
 openssl req -new -key rsaPrivate.pem -out rsaCertReq.csr
 
 openssl x509 -req -days 3650 -in rsaCertReq.csr -signkey rsaPrivate.pem -out rsaCert.crt
 
 openssl x509 -outform der -in rsaCert.crt -out rsaCert.der
 
 openssl pkcs12 -export -out rsaPrivate.p12 -inkey rsaPrivate.pem -in rsaCert.crt
 
 */
