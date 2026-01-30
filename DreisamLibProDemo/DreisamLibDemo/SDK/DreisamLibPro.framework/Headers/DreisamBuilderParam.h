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

/// APP id，Required
@property (nonatomic, strong) NSString *appId;

/// Hide log，Default no
@property (nonatomic, assign) BOOL hideLog;

/// Extra Parameters
@property (nonatomic, strong) NSDictionary *extraParameters;

@end

NS_ASSUME_NONNULL_END
