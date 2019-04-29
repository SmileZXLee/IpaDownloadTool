//
//  ZXIpaGetVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//

#import "ZXIpaGetVC.h"
#import "ZXIpaHttpRequest.h"
#import "ZXIpaModel.h"
#import "SGQRCodeScanningVC.h"

#import "ZXIpaHisVC.h"
#import "ZXLocalIpaVC.h"
@interface ZXIpaGetVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) ZXPlaceView *placeView;
@end

@implementation ZXIpaGetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

#pragma mark - 初始化视图
-(void)initUI{
    self.navigationController.navigationBar.translucent = NO;
    self.title = MainTitle;
    UIBarButtonItem *hisItem = [[UIBarButtonItem alloc]initWithTitle:@"历史" style:UIBarButtonItemStyleDone target:self action:@selector(historyAction)];
    UIBarButtonItem *downloadedItem =  [[UIBarButtonItem alloc]initWithTitle:@"已下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadedItemAction)];
    self.navigationItem.leftBarButtonItems = @[hisItem,downloadedItem];
    
    UIBarButtonItem *inputItem =  [[UIBarButtonItem alloc]initWithTitle:@"网址" style:UIBarButtonItemStyleDone target:self action:@selector(inputAction)];
    UIBarButtonItem *qrcodeItem =  [[UIBarButtonItem alloc]initWithTitle:@"二维码" style:UIBarButtonItemStyleDone target:self action:@selector(qrcodeItemAction)];
    self.navigationItem.rightBarButtonItems = @[inputItem,qrcodeItem];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque =NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZXPlaceView *placeView = [ZXPlaceView showWithNotice:@"点击右上角开始" superV:self.view];
        self.placeView = placeView;
    });
    
}

#pragma mark - Actions
#pragma mark 点击了历史
-(void)historyAction{
    ZXIpaHisVC *VC = [[ZXIpaHisVC alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark 点击了已下载
-(void)downloadedItemAction{
    ZXLocalIpaVC *VC = [[ZXLocalIpaVC alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark 点击了二维码
-(void)qrcodeItemAction{
    SGQRCodeScanningVC *VC = [[SGQRCodeScanningVC alloc] init];
    VC.resultBlock = ^(NSString *resultStr) {
        [self handelWithUrlStr:resultStr];
    };
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark 点击了网址
-(void)inputAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"输入下载页URL" message:@"等待网页加载完毕点击下载即可自动拦截ipa下载链接" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *inputTf = alertController.textFields[0];
        [inputTf becomeFirstResponder];
        NSString *urlStr = inputTf.text;
        if(!urlStr.length){
            self.title = @"URL不得为空";
            return;
        }
        [self handelWithUrlStr:urlStr];
        
    }];
    [alertController addThemeAction:cancelAction];
    [alertController addThemeAction:confirmAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入URL";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        NSString *cacheUrlStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"cacheUrlStr"];
        if(cacheUrlStr){
            textField.text = cacheUrlStr;
        }
        
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - UIWebViewDelegate
#pragma mark 网页将要开始加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    self.title = @"加载中...";
    NSString *urlStr = request.URL.absoluteString;
    if([urlStr hasPrefix:@"itms-services://"]){
        urlStr = [urlStr getPlistPathUrlStr];
        NSMutableURLRequest *newPlistReq;
        newPlistReq = [request mutableCopy];
        newPlistReq.URL = [NSURL URLWithString:urlStr];
        [ZXIpaHttpRequest downLoadWithUrlStr:urlStr callBack:^(BOOL result, id  _Nonnull data) {
            if(result){
                NSDictionary *plistDic = [[NSDictionary alloc]initWithContentsOfFile:data];
                ZXIpaModel *ipaModel = [[ZXIpaModel alloc]initWithDic:plistDic];
                ipaModel.fromPageUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"cacheUrlStr"];
                NSArray *sameArr = [ZXIpaModel zx_dbQuaryWhere:[NSString stringWithFormat:@"sign='%@'",ipaModel.sign]];
                if(sameArr.count){
                    ipaModel.localPath = [sameArr.firstObject valueForKey:@"localPath"];
                    [ipaModel zx_dbUpdateWhere:[NSString stringWithFormat:@"sign='%@'",ipaModel.sign]];
                }else{
                    [ipaModel zx_dbSave];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ALToastView showToastWithText:[NSString stringWithFormat:@"[%@]IPA信息已保存，点击左上角查看",ipaModel.title]];
                    self.title = MainTitle;
                });
                
            }
        }];
        
        return NO;
    }
    
    return YES;
}
#pragma mark 网页已经开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    
}
#pragma mark 网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.title = MainTitle;
}
#pragma mark 网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSString *errInfo = error.localizedDescription;
    if(!errInfo)return;
    if(![errInfo isEqualToString:@"Frame load interrupted"]){
        self.title = @"加载失败";
        [ALToastView showToastWithText:errInfo];
    }
}

#pragma mark - private
#pragma mark 处理url
-(void)handelWithUrlStr:(NSString *)urlStr{
    if(![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"]){
        urlStr = [@"http://" stringByAppendingString:urlStr];
    }
    urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    if(!url){
        self.title = @"URL无效";
        return;
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
    [[NSUserDefaults standardUserDefaults]setObject:urlStr forKey:@"cacheUrlStr"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if(self.placeView){
        [self.placeView removeFromSuperview];
    }
    self.title = @"加载中...";
}
@end
