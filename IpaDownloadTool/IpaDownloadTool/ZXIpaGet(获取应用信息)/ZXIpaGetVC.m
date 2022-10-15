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
#import "NSString+ZXMD5.h"

#import "ZXIpaHisVC.h"
#import "ZXIpaDetailVC.h"
#import "ZXLocalIpaVC.h"
#import "ZXIpaUrlHisVC.h"
@interface ZXIpaGetVC ()<UIWebViewDelegate,NJKWebViewProgressDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *githubBtn;
@property (weak, nonatomic) IBOutlet UIButton *versionBtn;
@property (weak, nonatomic) IBOutlet UIButton *webBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *webNextBtn;
@property (weak, nonatomic) IBOutlet UIButton *webReloadBtn;


@property (strong, nonatomic)NJKWebViewProgressView *progressView;
@property (strong, nonatomic)NJKWebViewProgress *progressProxy;
@property (copy, nonatomic)NSString *urlStr;
@property (copy, nonatomic)NSString *currentUrlStr;
@property (assign, nonatomic)BOOL urlStartHandled;
@property (copy, nonatomic)NSString *ignoredIpaDownloadUrl;
@end

@implementation ZXIpaGetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if(self.progressView){
        CGRect barFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 2);
        self.progressView.frame = barFrame;
        self.progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    }
}

#pragma mark - 初始化视图
-(void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.webReloadBtn.enabled = NO;
    self.webBackBtn.enabled = NO;
    self.webNextBtn.enabled = NO;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
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
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    [self.githubBtn setTitleColor:MainColor forState:UIControlStateNormal];
    [self.versionBtn setTitleColor:MainColor forState:UIControlStateDisabled];
    [self.versionBtn setTitle:[NSString stringWithFormat:@"%@ v%@(%@)",appName,appVersion,appBuild] forState:UIControlStateDisabled];
    UIScreenEdgePanGestureRecognizer *panGes = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(goBackAction:)];
    panGes.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:panGes];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initWebViewProgressView];
    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pasteboardStrLoadUrl:) name:ZXPasteboardStrLoadUrlNotification object:nil];
    
    if (@available(iOS 15.0, *)) {
       UINavigationBarAppearance *appperance = [[UINavigationBarAppearance alloc]init];
       appperance.backgroundColor = [UIColor whiteColor];
       self.navigationController.navigationBar.standardAppearance = appperance;
       self.navigationController.navigationBar.scrollEdgeAppearance = appperance;
    }
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


- (IBAction)webReloadAction:(id)sender {
    [self handleUrlLoad:self.currentUrlStr shouldCache:NO];
}

- (IBAction)webBackAction:(id)sender {
    if(self.webView.canGoBack){
        [self.webView goBack];
    }
}

- (IBAction)webNextAction:(id)sender {
    if(self.webView.canGoForward){
        [self.webView goForward];
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
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
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
        self.urlStartHandled = YES;
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"此网页想要安装一个描述文件，IPA提取器无法处理这个描述文件，请使用Safari打开并重新点击下载/安装按钮安装此描述文件，安装后Safari会自动加载一个新的链接，请在安装描述文件后复制Safari中的链接并粘贴到IPA提取器中即可获取IPA安装信息。" preferredStyle:UIAlertControllerStyleAlert];
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
    if([[urlStr pathExtension] isEqualToString:@"ipa"] || [urlStr containsString:@".ipa&"]){
        if (!(self.self.ignoredIpaDownloadUrl && [self.ignoredIpaDownloadUrl isEqualToString:urlStr])){
            __block NSString *urlStrWithoutQuery = [urlStr regularWithPattern:@"^.*?\\.ipa"];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前访问的地址可能是ipa文件下载地址，也可能是一个网页，请确认操作以继续！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"当作ipa文件下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ZXIpaModel *ipaModel = [[ZXIpaModel alloc]init];
                if(!urlStrWithoutQuery || !urlStrWithoutQuery.length){
                    urlStrWithoutQuery = urlStr;
                }
                ipaModel.title = [[[urlStrWithoutQuery lastPathComponent] stringByDeletingPathExtension] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                ipaModel.downloadUrl = urlStr;
                ipaModel.sign = [ipaModel.downloadUrl md5Str];
                [self saveIpaModel:ipaModel];
                ZXLocalIpaVC *VC = [[ZXLocalIpaVC alloc]init];
                VC.ipaModel = ipaModel;
                [self.navigationController pushViewController:VC animated:YES];
            }];
            UIAlertAction *loadAction = [UIAlertAction actionWithTitle:@"当作网页访问" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.ignoredIpaDownloadUrl = urlStr;
                [self handleUrlLoad:urlStr shouldCache:NO];
            }];
            [alertController addThemeAction:cancelAction];
            [alertController addThemeAction:downloadAction];
            [alertController addThemeAction:loadAction];
            [self presentViewController:alertController animated:YES completion:nil];
            self.title = MainTitle;
            return NO;
        }else{
            self.ignoredIpaDownloadUrl = NULL;
        }
        
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
                [self saveIpaModel:ipaModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"已成功提取“%@”的ipa信息，可在【历史】中查看！",ipaModel.title] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"查看详情" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        ZXIpaDetailVC *VC = [[ZXIpaDetailVC alloc]init];
                        VC.ipaModel = ipaModel;
                        [self.navigationController pushViewController:VC animated:YES];
                    }];
                    [alertController addThemeAction:cancelAction];
                    [alertController addThemeAction:confirmAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    self.title = MainTitle;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:[NSString stringWithFormat:@"plist文件下载失败，失败原因为:%@",((NSError *)data).localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
                    
                    [alertController addThemeAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
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
    self.versionBtn.hidden = YES;
    
    self.webBackBtn.enabled = self.webView.canGoBack;
    self.webNextBtn.enabled = self.webView.canGoForward;
    
    NSString *jsGetFavicon = @"var getFavicon=function(){var favicon=undefined;var nodeList=document.getElementsByTagName('link');for(var i=0;i<nodeList.length;i++){if((nodeList[i].getAttribute('rel')=='icon')||(nodeList[i].getAttribute('rel')=='shortcut icon')){favicon=nodeList[i].getAttribute('href')}}return favicon};getFavicon();";
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    self.currentUrlStr = url;
    self.webReloadBtn.enabled = YES;
    if(self.urlStartHandled){
        NSString *protocol = [webView stringByEvaluatingJavaScriptFromString:@"location.protocol"];
        NSString *host = [NSString stringWithFormat:@"%@//%@",protocol,[webView stringByEvaluatingJavaScriptFromString:@"location.host"]];
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
            NSString *oldUrlStr = ((ZXIpaUrlHisModel *)sameArr[0]).urlStr;
            if(oldUrlStr && oldUrlStr.length){
                urlHisModel.title = ((ZXIpaUrlHisModel *)sameArr[0]).title;
            }
        }
        [urlHisModel zx_dbSave];
    }
    self.urlStartHandled = NO;
   
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
    self.urlStartHandled = YES;
}

-(void)pasteboardStrLoadUrl:(NSNotification *)nf{
    NSString *urlStr = nf.object;
    self.urlStr = urlStr;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)saveIpaModel:(ZXIpaModel *)ipaModel{
    NSArray *sameArr = [ZXIpaModel zx_dbQuaryWhere:[NSString stringWithFormat:@"sign='%@'",ipaModel.sign]];
    ipaModel.localPath = [sameArr.firstObject valueForKey:@"localPath"];
    if(sameArr.count){
        [ZXIpaModel zx_dbDropWhere:[NSString stringWithFormat:@"sign='%@'",ipaModel.sign]];
    }
    ipaModel.fromPageUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"cacheUrlStr"];
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    ipaModel.time = [format stringFromDate:date];
    [ipaModel zx_dbSave];
}

- (void)handleUrlLoad:(NSString *)urlStr shouldCache:(BOOL)shouldCache{
    if(![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"]){
        urlStr = [@"http://" stringByAppendingString:urlStr];
    }
    _urlStr = urlStr;
    NSURL *url = [NSURL URLWithString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL,kCFStringEncodingUTF8))];
    if(!url){
        self.title = @"URL无效";
        self.progressView.alpha = 0;
        return;
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
    if(shouldCache){
        [[NSUserDefaults standardUserDefaults]setObject:urlStr forKey:@"cacheUrlStr"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    [self removePlaceView];
    self.title = @"加载中...";
}

#pragma mark setter

- (void)setUrlStr:(NSString *)urlStr{
    [self handleUrlLoad:urlStr shouldCache:YES];
}
@end
