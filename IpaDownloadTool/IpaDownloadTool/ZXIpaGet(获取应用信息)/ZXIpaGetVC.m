//
//  ZXIpaGetVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import "ZXIpaGetVC.h"
#import "ZXIpaHttpRequest.h"
#import "ZXIpaModel.h"
#import "SGQRCodeScanningVC.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#import "ZXIpaHisVC.h"
#import "ZXLocalIpaVC.h"
@interface ZXIpaGetVC ()<UIWebViewDelegate,NJKWebViewProgressDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *githubBtn;
@property (strong, nonatomic)NJKWebViewProgressView *progressView;
@property (strong, nonatomic)NJKWebViewProgress *progressProxy;
@property (copy, nonatomic)NSString *urlStr;
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
    self.webView.opaque = NO;
    self.webView.scalesPageToFit = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showPlaceViewWithText:@"点击右上角开始"];
    });
    [self.githubBtn setTitleColor:MainColor forState:UIControlStateNormal];
    UIScreenEdgePanGestureRecognizer *panGes = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(goBackAction:)];
    panGes.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:panGes];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initWebViewProgressView];
    });
    
}

- (void)initWebViewProgressView{
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = _progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    CGRect barFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 2);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.progressBarView.backgroundColor = MainColor;
    [self.view addSubview:self.progressView];
    self.progressView.alpha = 0;
}

#pragma mark - Actions
#pragma mark 点击了github地址
- (IBAction)githubAction:(UIButton *)sender {
    NSString *urlStr = sender.currentTitle;
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication]canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}
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
    if(![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        [ALToastView showToastWithText:@"摄像头不可用"];
        return;
    }
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

#pragma mark 网页返回上一级
- (void)goBackAction:(UIScreenEdgePanGestureRecognizer *)panGes{
    if (panGes.state == UIGestureRecognizerStateEnded || panGes.state == UIGestureRecognizerStateCancelled) {
        if([self.webView canGoBack]){
            [self.webView goBack];
        }else{
            [self historyAction];
        }
    }
}
#pragma mark - UIWebViewDelegate
#pragma mark 网页将要开始加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    self.title = @"加载中...";
    self.progressView.alpha = 1;
    NSString *urlStr = request.URL.absoluteString;
    if([urlStr hasSuffix:@".mobileprovision"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"此网页想要安装一个描述文件，IpaDownloadTool无法处理这个描述文件，请使用Safari打开并安装此描述文件，安装后Safari会自动加载一个新的链接，请在安装描述文件后复制Safari中的链接并粘贴到IpaDownloadTool中即可获取IPA安装信息。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"跳转到Safari打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:urlStr];
            if([[UIApplication sharedApplication]canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }else{
                [ALToastView showToastWithText:@"无法安装此描述文件"];
            }
        }];
        [alertController addThemeAction:cancelAction];
        [alertController addThemeAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    if([urlStr hasPrefix:@"itms-services://"] || [urlStr containsString:@"itemService="]){
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
        if(![urlStr containsString:@"itemService="]){
            return NO;
        }
    }
    
    return YES;
}
#pragma mark 网页已经开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    
}
#pragma mark 网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.title = MainTitle;
    self.githubBtn.hidden = YES;
}
#pragma mark 网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSString *errInfo = error.localizedDescription;
    if(!errInfo)return;
    if(![errInfo isEqualToString:@"Frame load interrupted"]){
        self.title = @"加载失败";
        self.progressView.alpha = 0;
        [ALToastView showToastWithText:errInfo];
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    [self.progressView setProgress:progress animated:YES];
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
        self.progressView.alpha = 0;
        return;
    }
    self.urlStr = urlStr;
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
    [[NSUserDefaults standardUserDefaults]setObject:urlStr forKey:@"cacheUrlStr"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self removePlaceView];
    self.title = @"加载中...";
}
@end
