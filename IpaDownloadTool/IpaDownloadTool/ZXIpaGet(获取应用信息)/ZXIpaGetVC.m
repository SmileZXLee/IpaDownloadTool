//
//  ZXIpaGetVC.m
//  IpaDownloadTool
//
//  Created by 李兆祥 on 2019/4/28.
//  Copyright © 2019 李兆祥. All rights reserved.
//  https://github.com/SmileZXLee/IpaDownloadTool

#import "ZXIpaGetVC.h"
#import "ZXIpaUrlHisModel.h"
#import "ZXIpaHttpRequest.h"
#import "ZXIpaModel.h"
#import "SGQRCodeScanningVC.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#import "ZXIpaHisVC.h"
#import "ZXLocalIpaVC.h"
#import "ZXIpaUrlHisVC.h"
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
    UIBarButtonItem *downloadedItem = [[UIBarButtonItem alloc]initWithTitle:@"已下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadedItemAction)];
    self.navigationItem.leftBarButtonItems = @[hisItem,downloadedItem];
    
    UIButton *inputBtn = [[UIButton alloc]init];
    [inputBtn addTarget:self action:@selector(inputAction) forControlEvents:UIControlEventTouchUpInside];
    [inputBtn setTitleColor:MainColor forState:UIControlStateNormal];
    inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [inputBtn setTitle:@"网址" forState:UIControlStateNormal];
    UILongPressGestureRecognizer *inputLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(inputLongPress:)];
    [inputBtn addGestureRecognizer:inputLongPressGestureRecognizer];
    UIBarButtonItem *inputItem = [[UIBarButtonItem alloc]initWithCustomView:inputBtn];
    UIBarButtonItem *qrcodeItem = [[UIBarButtonItem alloc]initWithTitle:@"二维码" style:UIBarButtonItemStyleDone target:self action:@selector(qrcodeItemAction)];
    self.navigationItem.rightBarButtonItems = @[inputItem,qrcodeItem];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    self.webView.scalesPageToFit = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showPlaceViewWithText:@"轻点【网址】开始，长按显示网址历史"];
    });
    [self.githubBtn setTitleColor:MainColor forState:UIControlStateNormal];
    UIScreenEdgePanGestureRecognizer *panGes = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(goBackAction:)];
    panGes.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:panGes];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initWebViewProgressView];
    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pasteboardStrLoadUrl:) name:ZXPasteboardStrLoadUrlNotification object:nil];
    
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
-(void)inputLongPress:(UILongPressGestureRecognizer *)gesture{
    if(gesture.state != UIGestureRecognizerStateBegan){
        return;
    }
    ZXIpaUrlHisVC *VC = [[ZXIpaUrlHisVC alloc]init];
    VC.urlSelectedBlock = ^(NSString * _Nonnull urlStr) {
        self.urlStr = urlStr;
    };
    [self.navigationController pushViewController:VC animated:YES];
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"此网页想要安装一个描述文件，IpaDownloadTool无法处理这个描述文件，请使用Safari打开并重新点击下载/安装按钮安装此描述文件，安装后Safari会自动加载一个新的链接，请在安装描述文件后复制Safari中的链接并粘贴到IpaDownloadTool中即可获取IPA安装信息。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"跳转到Safari打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:self.urlStr];
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
                ipaModel.localPath = [sameArr.firstObject valueForKey:@"localPath"];
                if(sameArr.count){
                    [ZXIpaModel zx_dbDropWhere:[NSString stringWithFormat:@"sign='%@'",ipaModel.sign]];
                }
                [ipaModel zx_dbSave];
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
    
    NSString *jsGetFavicon = @"var getFavicon=function(){var favicon=undefined;var nodeList=document.getElementsByTagName('link');for(var i=0;i<nodeList.length;i++){if((nodeList[i].getAttribute('rel')=='icon')||(nodeList[i].getAttribute('rel')=='shortcut icon')){favicon=nodeList[i].getAttribute('href')}}return favicon};getFavicon();";
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    if([url isEqualToString:self.urlStr]){
        NSString *host = [webView stringByEvaluatingJavaScriptFromString:@"location.hostname"];
        NSString *favicon = [webView stringByEvaluatingJavaScriptFromString:jsGetFavicon];
        if(favicon.length > 0 && ![favicon hasPrefix:@"http"]){
            favicon = [host stringByAppendingString:favicon];
        }
        if(!favicon.length){
            favicon = [NSString stringWithFormat:@"%@/favicon.ico",host];
        }
        ZXIpaUrlHisModel *urlHisModel = [[ZXIpaUrlHisModel alloc]init];
        urlHisModel.hostStr = host;
        urlHisModel.urlStr = url;
        urlHisModel.title = title;
        urlHisModel.favicon = favicon;
        NSArray *sameArr = [ZXIpaUrlHisModel zx_dbQuaryWhere:[NSString stringWithFormat:@"urlStr='%@'",urlHisModel.urlStr]];
        if(sameArr.count){
            [ZXIpaUrlHisModel zx_dbDropWhere:[NSString stringWithFormat:@"urlStr='%@'",urlHisModel.urlStr]];
        }
        [urlHisModel zx_dbSave];
    }
    
   
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
    self.urlStr = urlStr;
}

- (void)pasteboardStrLoadUrl:(NSNotification *)nf{
    NSString *urlStr = nf.object;
    self.urlStr = urlStr;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark setter

- (void)setUrlStr:(NSString *)urlStr{
    if(![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"]){
        urlStr = [@"http://" stringByAppendingString:urlStr];
    }
    urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _urlStr = urlStr;
    NSURL *url = [NSURL URLWithString:urlStr];
    if(!url){
        self.title = @"URL无效";
        self.progressView.alpha = 0;
        return;
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
    [[NSUserDefaults standardUserDefaults]setObject:urlStr forKey:@"cacheUrlStr"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self removePlaceView];
    self.title = @"加载中...";
}
@end
