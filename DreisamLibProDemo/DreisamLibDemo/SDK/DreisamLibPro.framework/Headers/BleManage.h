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

/// Binding device
/// - Parameters:
///   - device: device sn
///   - resultCallback: resultCallback
///   - processProgress: processProgress
- (void)bindDevice:(NSString *)device resultCallback:(void(^)(DreisamBindingProcessState state, DreisamDeviceModel *deviceModel))resultCallback processProgress:(void (^)(DreisamBindingProcessState state))processProgress;

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
- (void)finshDevice:(void(^)(DreisamEnumState state))callback;

@end
