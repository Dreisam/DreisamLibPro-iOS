//
//  DreisamBuilderParam.h
//  DreisamLibPro
//
//  Created by List on 2026/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DreisamBuilderParam : NSObject

/// Server identity，Required
@property (nonatomic, strong) NSString *server;

/// License，Required
@property (nonatomic, strong) NSString *license;

/// Hide log，Default no
@property (nonatomic, assign) BOOL hideLog;

/// Extra Parameters
@property (nonatomic, strong) NSDictionary *extraParameters;

@end

NS_ASSUME_NONNULL_END
