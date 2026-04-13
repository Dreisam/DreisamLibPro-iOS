//
//  DeviceManage.h
//  DreisamLibPro
//
//  Created by List on 2026/1/9.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <DreisamLibPro/DreisamEnum.h>
#import <DreisamLibPro/DreisamGlucoseModel.h>
#import <DreisamLibPro/DreisamDeviceModel.h>

@protocol BleManage <NSObject>

/// Bluetooth status
@property (nonatomic, assign, readonly) DreisamEnumState state;


/// Set blood glucose range, default 3.9-11.1
/// - Parameters:
///   - targetHighValue: targetHighValue
///   - targetLowValue: targetLowValue
- (BOOL)setGlucoseTargetHighValue:(CGFloat)targetHighValue targetLowValue:(CGFloat)targetLowValue;


/// Binding device
/// - Parameters:
///   - device: device sn
///   - processProgress: processProgress
///   - successCallback: successCallback
///   - errorCallback: errorCallback（code
                        ///41002    // （The user has an activated device）用户存在已激活的设备
                        ///42001    // （Device does not exist）设备不存在
                        ///42002    // （The device is bound）设备已被绑定
                        ///10000    //（Network error or server error）网络错误或者服务器错误
                        ///10002    // （120-second binding timeout）120秒绑定超时）
- (void)bindDevice:(NSString *)device processProgress:(void (^)(DreisamBindingProcessState state))processProgress successCallback:(void(^)(DreisamDeviceModel *deviceModel))successCallback errorCallback:(void (^)(NSInteger code, NSString *msg))errorCallback;


/// cancel
- (void)cancelBind;


/// Connect the device
/// - Parameters:
///   - callback: callback
- (void)connectDeviceCallback:(void(^)(DreisamEnumState state))callback;


/// Callback Bluetooth status and SDK exception status
- (void)connectBleStateWithExceptionEventCallback:(void(^)(DreisamEnumState state))callback;


/// Data synchronization starts
- (void)dataSyncStartCallback:(void(^)(int totalCount))callback;


/// Data synchronization progress
- (void)dataSyncProgressCallback:(void(^)(int progress))callback;


/// Data synchronization complete
- (void)dataSyncCompleteCallback:(void(^)(NSArray <DreisamGlucoseModel*> *glucoseModelAry))callback;


/// Three minutes of real-time data
- (void)realTimeDataCallBack:(void(^)(DreisamGlucoseModel *glucoseModel))callback;


/// Get the signal value of the Bluetooth device
/// - Parameter callback: callback
- (void)getRSSICallback:(void(^)(NSNumber *rssi))callback;


/// End the device life cycle
///   - errorCallback: errorCallback（code
                    ///42001    // （Device does not exist）设备不存在
                    ///10000    //（Network error or server error）网络错误或者服务器错误
- (void)finshDeviceSuccessCallback:(void(^)(void))successCallback errorCallback:(void (^)(NSInteger code, NSString *msg))errorCallback;

@end
