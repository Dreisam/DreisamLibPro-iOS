//
//  DHomeVC.m
//  DreisamLibDemo
//
//  Created by List on 2025/12/18.
//

#import "DHomeVC.h"
#import "DQrCodeSacnVC.h"
#import "DHomeHeaderView.h"
#import "NSDate+XTDate.h"
#import "MJExtension.h"
#import "DLoginVC.h"
#import "DNavVC.h"
#import "AppDelegate.h"

@interface DHomeVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *baseTableView;
@property (nonatomic, strong) DHomeHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray <DreisamGlucoseModel *>*glucoseAry;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation DHomeVC

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (UITableView *)baseTableView{
    if (!_baseTableView) {
        _baseTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _baseTableView.frame = self.view.bounds;
        _baseTableView.rowHeight = 50;
        _baseTableView.delegate = self;
        _baseTableView.dataSource = self;
        _baseTableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:248/255.0 blue:239/255.0 alpha:1];
        [self.view addSubview:_baseTableView];
    }
    return _baseTableView;
}

- (NSMutableArray *)glucoseAry{
    if (!_glucoseAry) {
        _glucoseAry = [NSMutableArray array];
    }
    return _glucoseAry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Home";
     
    self.headerView = [DHomeHeaderView new];
    self.headerView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300);
    self.baseTableView.tableHeaderView = self.headerView;
    
     
    // init
    [self initDreisamSDK];
    
     
    /// cache
    NSMutableArray *ary = [[NSUserDefaults standardUserDefaults] objectForKey:BLE_My_Glucose_Ary_Key];
    self.glucoseAry = [DreisamGlucoseModel mj_objectArrayWithKeyValuesArray:ary];
    [self setGlucoseTitleFrom:self.glucoseAry.firstObject];
    [self.baseTableView reloadData];

      
    /// delete device
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(delete)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    /// send log
    UIBarButtonItem *sendLogButton = [[UIBarButtonItem alloc] initWithTitle:@"Send log" style:UIBarButtonItemStylePlain target:(AppDelegate *)[UIApplication sharedApplication].delegate action:@selector(sendLog)];
    self.navigationItem.leftBarButtonItem = sendLogButton;
}

- (void)delete{
    
    __weak typeof(self)weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add Device（添加设备）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:BLE_My_Device_Model_key]) {
            [ListHub showText:@"Existing devices" maskBackgroudEdit:YES];
            return;
        }
        
        DQrCodeSacnVC *vc = [DQrCodeSacnVC new];
        vc.isAddDevice = YES;
        vc.codeCompletion = ^(NSString * _Nonnull code) {
            [weakSelf.headerView setBleRealConditionLabelState:DreisamEnumStateConnected];
            [weakSelf.headerView setShowloading:NO];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Log out（退出登录）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf logOut];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Finsh device（结束生命周期）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DreisamLibManage.shareLib.bleManage finshDevice:^(DreisamEnumState state) {
            if (state==DreisamEnumStateOperationSucceeded) {
                [ListHub showText:@"operation succeeded" maskBackgroudEdit:YES];
                 
                [weakSelf clearDeviceAllData];
                
            }else{
                [ListHub showText:@"operation failure" maskBackgroudEdit:YES];
            }
        }];
        
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    // 弹出
    [self presentViewController:alert animated:YES completion:nil];
    
    
}


#pragma mark ------ DreisamLib
- (void)initDreisamSDK{
    
    __weak typeof(self)weakSelf = self;
    
    ///init SDK
    DreisamBuilderParam *builder = DreisamBuilderParam.new;
    builder.server = @"xxx";
    builder.appId = @"xxx";
    [[DreisamLibManage shareLib] initSDKBuilderParam:builder];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:BLE_My_User_Login_Key];
    [DreisamLibManage.shareLib loginUserToken:token callback:^(DreisamEnumState state, DreisamDeviceModel * _Nonnull deviceModel) {
        if (state==DreisamEnumStateLoginSucceed) {
            [ListHub hide];
            [ListHub showText:@"login succeed" maskBackgroudEdit:YES];
            
            [DreisamLibManage.shareLib.bleManage connectDeviceCallback:^(DreisamEnumState state) {
                
            }];

            // 登录返回设备模型，这里可以进行显示名字之类的
            NSData *jsonData = [[deviceModel mj_keyValues] mj_JSONData];
            [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:BLE_My_Device_Model_key];
            [[NSUserDefaults standardUserDefaults] synchronize];
             
            if (jsonData) {
                [weakSelf.headerView setShowloading:DreisamLibManage.shareLib.bleManage.state==DreisamEnumStateIndicateLoading?YES:NO];
                [weakSelf.headerView setBleRealConditionLabelState:DreisamEnumStateDisconnect];
            }
        }else{
            [ListHub showText:@"login failure" maskBackgroudEdit:YES];
        }
    }];

    
    /// Set the data and status callbacks
    [[DreisamLibManage shareLib].bleManage connectBleStateWithExceptionEventCallback:^(DreisamEnumState state) {
        [weakSelf.headerView setBleRealConditionLabelState:state];
        if (state==DreisamEnumStateIndicateLoading) {
            [weakSelf.headerView setShowloading:YES];
        }else if(state==DreisamEnumStateConnected){
            [weakSelf.headerView setShowloading:NO];
            
            [[DreisamLibManage shareLib].bleManage getRSSICallback:^(NSNumber *rssi) {
                weakSelf.headerView.rssiLabel.text = [NSString stringWithFormat:@"Bluetooth rssi：%@",rssi.stringValue];
            }];
        }else if(state==DreisamEnumStateAuthenticationFailure){
            [ListHub showText:@"Verification failed" maskBackgroudEdit:YES];
        }else if(state==DreisamEnumStateTokenInvalid || state==DreisamEnumStateTokenExpiration){
            [weakSelf logOut];
        }else if(state==DreisamEnumStateUnDeviceExpire){
            
            [ListHub showText:@"Device Expire" maskBackgroudEdit:YES];
            
            [weakSelf clearDeviceAllData];
            
        }
        
        //        else if(state==DreisamEnumStateDisconnect){
        //[weakSelf.headerView setShowloading:YES];
        //        }
        
    }];
    
    
    [[DreisamLibManage shareLib].bleManage dataSyncStartCallback:^(int totalCount){
        weakSelf.headerView.dataSyncLabel.text = @"Data sync：0％";
    }];
    
    [[DreisamLibManage shareLib].bleManage dataSyncProgressCallback:^(int progress) {
        //NSLog(@"dataSyncProgressCallback = %d",progress);
        weakSelf.headerView.dataSyncLabel.text = [NSString stringWithFormat:@"Data sync：%d％",progress];
    }];
    
    [[DreisamLibManage shareLib].bleManage dataSyncCompleteCallback:^(NSArray<DreisamGlucoseModel *> *glucoseModelAry) {
        weakSelf.headerView.dataSyncLabel.text = @"Data sync：100％";
        
        //set
        [weakSelf setGlucoseTitleFrom:glucoseModelAry.lastObject];
        
        //save
        [weakSelf saveGlucoseAry:glucoseModelAry];
        
    }];
    
    
    [[DreisamLibManage shareLib].bleManage realTimeDataCallBack:^(DreisamGlucoseModel *glucoseModel) {
        
        weakSelf.headerView.dataSyncLabel.text = @"Data sync：100％";
        
        //set
        [weakSelf setGlucoseTitleFrom:glucoseModel];
        
        // save
        [weakSelf saveGlucoseAry:[NSArray arrayWithObject:glucoseModel]];
        
        
        [[DreisamLibManage shareLib].bleManage getRSSICallback:^(NSNumber *rssi) {
            weakSelf.headerView.rssiLabel.text = [NSString stringWithFormat:@"Bluetooth rssi：%@",rssi.stringValue];
        }];
        
    }];
    
    
}


#pragma mark ----UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.glucoseAry.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"A";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.backgroundColor = UIColor.whiteColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    DreisamGlucoseModel *model = self.glucoseAry[indexPath.row];
    NSString *createTime = [model.createTime toTimeStrWithDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",createTime];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ mmol/L",model.glucose];
    return cell;
}
 


- (void)saveGlucoseAry:(NSArray *)glucoseAry{
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:BLE_My_Glucose_Ary_Key]];
    if (!ary.count) {
        ary = [NSMutableArray array];
    }
    
    for (DreisamGlucoseModel *m in glucoseAry) {
        NSDictionary *userDict = [m mj_keyValues];
        [ary insertObject:userDict atIndex:0];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:ary] forKey:BLE_My_Glucose_Ary_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
     
    NSMutableArray *tempAllAry = [[NSUserDefaults standardUserDefaults] objectForKey:BLE_My_Glucose_Ary_Key];
    self.glucoseAry = [DreisamGlucoseModel mj_objectArrayWithKeyValuesArray:tempAllAry];
    [self.baseTableView reloadData];
     
}

- (void)setGlucoseTitleFrom:(DreisamGlucoseModel *)model{
    if (model) {
        NSString *createTime = [model.createTime toTimeStrWithDateFormat:@"HH:mm"];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@mmol/L\n%@",[self getTrendStrWithTrend:model.trend],model.glucose,createTime]];
        
        [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:50] range:NSMakeRange(1, model.glucose.length+1)];
        [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(1, model.glucose.length+1)];
        self.headerView.glucoseLabel.attributedText = AttributedStr;
    }else{
        self.headerView.glucoseLabel.text = @"--";
    }
}


- (NSString *)getTrendStrWithTrend:(NSString *)trend{
    if (trend.length==0) {
        return @"";
    }
    NSDictionary *dic = @{@"15":@"↑",
                          @"20":@"↓",
                          @"1":@"→",
                          @"5":@"↗︎",
                          @"10":@"↘︎",
    };
    
    NSString *tren = dic[trend];
    if(!tren){
        tren = @"→";
    }
    return tren;
}


- (void)logOut{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:BLE_My_User_Login_Key];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:BLE_My_Glucose_Ary_Key];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:BLE_My_Device_Model_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
             
    [DreisamLibManage.shareLib logout];
    
    [ListHub showLoadingText:nil maskBackgroudEdit:NO showForever:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ListHub hide];
        DLoginVC *vc = [DLoginVC new];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.window.rootViewController = [[DNavVC alloc] initWithRootViewController:vc];
    });
}


- (void)clearDeviceAllData{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:BLE_My_Glucose_Ary_Key];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:BLE_My_Device_Model_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.glucoseAry removeAllObjects];
    
    self.headerView.glucoseLabel.text = @"--";
    self.headerView.connectStateLabel.text = @"--";
    self.headerView.dataSyncLabel.text = @"--";
    self.headerView.bleRealConditionLabel.text = @"--";
    self.headerView.rssiLabel.text = @"--";

    [self.baseTableView reloadData];
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
