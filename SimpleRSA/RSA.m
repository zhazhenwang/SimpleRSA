//
//  RSA.m
//  SimpleRSA
//
//  Created by Zhenwang Zha on 15/7/13.
//  Copyright (c) 2015年 zhenwang. All rights reserved.
//

#import "RSA.h"

@implementation RSA

- (NSString *)encryptRSA:(NSString *)plainText {
    SecKeyRef publicKey = [self getPublicKey];
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    uint8_t *nonce = (uint8_t *) [plainText UTF8String];
    SecKeyEncrypt(publicKey,
            kSecPaddingPKCS1,
            nonce,
            strlen((char *) nonce),
            &cipherBuffer[0],
            &cipherBufferSize);
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    free(cipherBuffer);
    return [encryptedData base64EncodedStringWithOptions:0];
}

- (NSString *)decryptRSA:(NSString *)plainText {
    SecKeyRef privateKey = [self getPrivateKey];
    size_t plainBufferSize = SecKeyGetBlockSize(privateKey);
    uint8_t *plainBuffer = malloc(plainBufferSize);
    NSData *incomingData = [[NSData alloc] initWithBase64EncodedString:plainText options:0];
    uint8_t *cipherBuffer = (uint8_t *) [incomingData bytes];
    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    SecKeyDecrypt(privateKey,
            kSecPaddingPKCS1,
            cipherBuffer,
            cipherBufferSize,
            plainBuffer,
            &plainBufferSize);
    NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    NSString *decryptedString = [[[NSString alloc] initWithData:decryptedData
                                                      encoding:NSUTF8StringEncoding] autorelease];
    [incomingData release];
    free(plainBuffer);
    return decryptedString;
}

- (SecKeyRef)getPublicKey {
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:resourcePath];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    SecKeyRef key = NULL;
    SecTrustRef trust = NULL;
    SecPolicyRef policy = NULL;
    
    if (cert != NULL) {
        policy = SecPolicyCreateBasicX509();
        if (policy) {
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
                SecTrustResultType result;
                if (SecTrustEvaluate(trust, &result) == noErr) {
                    key = SecTrustCopyPublicKey(trust);
                }
            }
        }
    }
    if (policy) CFRelease(policy);
    if (trust) CFRelease(trust);
    if (cert) CFRelease(cert);
    return key;
}

- (SecKeyRef)getPrivateKey {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"p12"];
    NSData *p12Data = [NSData dataWithContentsOfFile:resourcePath];
    
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    
    SecKeyRef privateKeyRef = NULL;
    
    //这里的密码改成实际私钥的密码
    [options setObject:@"111111" forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef) p12Data,
                                             (__bridge CFDictionaryRef)options, &items);
    
    if (securityError == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp =
        (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                             kSecImportItemIdentity);
        
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError != noErr) {
            privateKeyRef = NULL;
        }
    }
    CFRelease(items);
    [options release];
    return privateKeyRef;
}

@end
