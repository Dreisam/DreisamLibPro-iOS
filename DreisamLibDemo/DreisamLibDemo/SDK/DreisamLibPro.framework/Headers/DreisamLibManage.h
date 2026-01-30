//
//  DreisamLibManage.h
//  DreisamLibPro
//
//  Created by List on 2026/1/9.
//

#import <Foundation/Foundation.h>
#include <DreisamLibPro/BleManage.h>
#include <DreisamLibPro/DreisamBuilderParam.h>
#include <DreisamLibPro/DreisamDeviceModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DreisamLibManage : NSObject

@property (nonatomic, strong, readonly) DreisamBuilderParam *builderParm;

/*
 * DeviceManage module
 */
@property (nonatomic, strong) id<BleManage>bleManage;


/*
 * initialization
 */
+ (instancetype)shareLib;


/// initialization
- (void)initSDKBuilderParam:(DreisamBuilderParam *)builderParam;


/// login
- (void)loginUserToken:(NSString *)token callback:(void(^)(DreisamEnumState state, DreisamDeviceModel *deviceModel))callback;


/// logout
- (void)logout;


///SDK version
- (NSString *)libVersion;

@end

NS_ASSUME_NONNULL_END
