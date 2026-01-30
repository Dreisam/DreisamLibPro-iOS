//
//  DQrCodeSacnVC.m
//  DreisamLibDemo
//
//  Created by List on 2025/12/19.
//

#import "DQrCodeSacnVC.h"
#import "QRCScanner.h"
#import "MJExtension.h"

@interface DQrCodeSacnVC ()<QRCodeScanneDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong)  QRCScanner *scanner;

@end

@implementation DQrCodeSacnVC
 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Scan";
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view addSubview:self.scanner];
}
 
-(QRCScanner *)scanner{
    if (!_scanner) {
        _scanner = [[QRCScanner alloc] initQRCScannerWithView:self.view];
        _scanner.delegate = self;
        _scanner.scanningLieColor=[UIColor cyanColor];
        _scanner.notSreachScannerBlock =^(UIButton *sender){
        };
    }
    return _scanner;
}


#pragma mark  - 扫描二维码成功后代理方法
- (void)didFinshedScanningQRCode:(NSString *)result{
    __weak typeof(self)weakSelf = self;
    
    if (self.isAddDevice) {
        [ListHub showLoadingText:nil maskBackgroudEdit:NO showForever:YES];
        [DreisamLibManage.shareLib.bleManage bindDevice:result resultCallback:^(DreisamBindingProcessState state, DreisamDeviceModel *deviceModel) {
            if (state==DreisamBindingProcessStateBindingFailure) {
                [ListHub showText:@"Binding failure" maskBackgroudEdit:YES];
            }else{
                [ListHub showText:@"Binding successful" maskBackgroudEdit:YES];

                // cache
                NSData *jsonData = [[deviceModel mj_keyValues] mj_JSONData];
                [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:BLE_My_Device_Model_key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                if (weakSelf.codeCompletion) {
                    weakSelf.codeCompletion(result);
                }
                
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                NSLog(@"resultCallback = %@",deviceModel.device_sn);

            }
            
        } processProgress:^(DreisamBindingProcessState state) {
            if (state==DreisamBindingProcessStateScanning) {
                [ListHub showLoadingText:@"Scanning" maskBackgroudEdit:NO showForever:YES];
            }else if (state==DreisamBindingProcessStateConnecting){
                [ListHub showLoadingText:@"Connecting" maskBackgroudEdit:NO showForever:YES];
            }else if (state==DreisamBindingProcessStateInBinding){
                [ListHub showLoadingText:@"InBinding" maskBackgroudEdit:NO showForever:YES];
            }
        }];
        
    }else{
        if (self.codeCompletion) {
            self.codeCompletion(result);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
