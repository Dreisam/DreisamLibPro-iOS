//
//  DreisamDeviceModel.h
//  DreisamLibPro
//
//  Created by List on 2026/1/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DreisamDeviceModel : NSObject

@property (nonatomic, strong) NSString *estimated_end_at;       /// expire date
@property (nonatomic, strong) NSString *device_sn;              /// sn
@property (nonatomic, strong) NSString *product_name;           /// product name
@property (nonatomic, strong) NSString *icon_url;               /// icon
@property (nonatomic, strong) NSString *bound_at;               /// bound time
@property (nonatomic, strong) NSString *activated_at;           /// activated time
///
@end

NS_ASSUME_NONNULL_END
