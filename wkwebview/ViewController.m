//
//  ViewController.m
//  wkwebview
//
//  Created by jsw_cool on 2021/4/25.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property(nonatomic,strong)WKWebView *webView;

@property(nonatomic,strong)UIBarButtonItem *backItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.webView];
    
    [self addLeftButton];
    
    NSString *url1=@"http://101.198.190.171:8889/popStack/index.html";
//    NSString *url2=@"http://101.198.190.171:8889/safeAreaDemo.html";
    
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url1]];
    
    [self.webView loadRequest:request];
    
}

- (void)addLeftButton
{
    self.navigationItem.leftBarButtonItem = self.backItem;
}


- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backNative)];
    }
    return _backItem;
}

//点击返回的方法
- (void)backNative
{
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
          //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItems = @[self.backItem];
    } else {
//        [self closeNative];
    }
}


- (WKWebView *)webView {
    if (_webView) {
        return _webView;
    }
    /*
     WKUserContentController主要是处理Javascript向webview发送消息的交互，addScriptMessageHandler方法注册了一个名为jsCallOC的方法用来和H5进行交互
     */
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"jsCallOC"];
    WKWebViewConfiguration* webViewConfig = [[WKWebViewConfiguration alloc] init];
    webViewConfig.userContentController = userContentController;
//    webViewConfig.processPool = [[self cookieManager] sharedProcessPool];
    webViewConfig.allowsInlineMediaPlayback = true;//支持视频页面内播放
    
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) configuration:webViewConfig];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.backgroundColor = [UIColor blackColor];
    _webView.opaque = NO;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.opaque = NO;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    _webView.scrollView.bounces = !self.disableBounces;
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    return _webView;
}

#pragma mark - WKNavigationDelegate

// 页面开始加载时调用(开始请求服务器并加载页面)
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{

}
// 当内容开始返回时调用(开始渲染页面时调用，响应的内容到达主页面的时候响应,刚准备开始渲染页面)
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{

}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{

}
/** 请求服务器发生错误 (如果是goBack时，当前页面也会回调这个方法，原因是NSURLErrorCancelled取消加载) */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{

}
/** 在收到响应后，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
/** 接收到服务器跳转请求即服务重定向时之后调用 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{

}
/** 收到服务器响应后，在发送请求之前，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

#pragma mark - WKUIDelegate
 /** 解决点击内部链接没有反应问题 */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
 /* 输入框 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}
 /* 确认框 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}

/* 警告框
 *  web界面中有弹出警告框时调用
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%@",message);
    completionHandler();
}

#pragma mark - WKScriptMessage
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}


//WKBackForwardList:之前访问过的 web页面的列表，可以通过后退和前进动作来访问到。
//WKBackForwardListItem: webview中后退列表里的某一个网页。
//WKFrameInfo: 包含一个网页的布局信息。
//WKNavigation: 包含一个网页的加载进度信息。
//WKNavigationAction:包含可能让网页导航变化的信息，用于判断是否做出导航变化。
//WKNavigationResponse:包含可能让网页导航变化的返回内容信息，用于判断是否做出导航变化。
//WKPreferences: 概括一个 webview 的偏好设置。
//WKProcessPool: 表示一个 web 内容加载池。
//WKUserContentController: 提供使用 JavaScript post 信息和注射 script 的方法。
//WKScriptMessage: 包含网页发出的信息。
//WKUserScript:表示可以被网页接受的用户脚本。
//WKWebViewConfiguration: 初始化 webview 的设置
//WKWindowFeatures: 指定加载新网页时的窗口属性。
//WKNavigationDelegate: 提供了追踪主窗口网页加载过程和判断主窗口和子窗口是否进行页面加载新页面的相关方法。
//WKScriptMessageHandler: 提供从网页中收消息的回调方法。
//WKUIDelegate: 提供用原生控件显示网页的方法回调。



@end
