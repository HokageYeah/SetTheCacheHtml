//
//  ViewController.m
//  SetTheCacheHtml
//
//  Created by 余晔 on 2017/6/23.
//  Copyright © 2017年 余晔. All rights reserved.
//

#import "ViewController.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "FTWCache.h"
#import "NSString+MD5.h"

#import "URLCache.h"

@interface ViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@property (nonatomic, retain) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self addButton];
    
    
    
    
    
    URLCache *sharedCache = [[URLCache alloc] initWithMemoryCapacity:1024 * 1024 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    CGRect frame = {{60, 200}, {200, 30}};
    UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textLabel];
    self.label = textLabel;
    
    if (![sharedCache.responsesInfo count]) { // not cached
        textLabel.text = @"缓存中…";
        
        [self.view addSubview:self.webView];

    } else {
        textLabel.text = @"已从硬盘读取缓存";
        [self addButton];
    }
    
}


- (void)addButton {
    CGRect frame = {{130, 400}, {60, 30}};
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"我点" forState:UIControlStateNormal];
    [self.view addSubview:button];
}

- (void)click {
    if (_webView) {
        [self.webView removeFromSuperview];
        self.webView = nil;
    } else {
        [self.view addSubview:self.webView];
    }
}


- (UIWebView *)webView
{
    if(!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        _webView.scalesPageToFit = YES;
        _webView.dataDetectorTypes = UIDataDetectorTypeAll;
        _webView.contentMode = UIViewContentModeRedraw;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://prebk.youjuke.com/redemption/index?platform=app&userId=1050"]]];

    }
    return _webView;
}


#pragma mark UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.webView = nil;
    _label.text = @"请接通网络再运行本应用";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView = nil;
    _label.text = @"缓存完毕";
    [self addButton];
    
    URLCache *sharedCache = (URLCache *)[NSURLCache sharedURLCache];
    [sharedCache saveInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (!_webView) {
        URLCache *sharedCache = (URLCache *)[NSURLCache sharedURLCache];
        [sharedCache removeAllCachedResponses];
    }
}

- (void)viewDidUnload {
    self.webView = nil;
    self.label = nil;
}


- (void)dealloc
{
    self.webView = nil;
    self.label = nil;
}










//#pragma mark UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
// 
//    return YES;
//}
//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    
//}
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    NSString *lenthurl = [self.webView stringByEvaluatingJavaScriptFromString:[self createImgArrayJavaScript]];
//    NSString *lenth = [self.webView stringByEvaluatingJavaScriptFromString:[self createGetImgNumJavaScript]];
//    NSArray *separString = [lenthurl componentsSeparatedByString:@";"];
//    NSMutableArray *difary = [NSMutableArray arrayWithArray:separString];
//    if(difary.count>0)
//    {
//        [difary removeObjectAtIndex:(difary.count-1)];
//    }
//    
//    NSLog(@"lenthurl：%@",lenthurl);
//    NSLog(@"lenth数量：%@",lenth);
//    NSLog(@"ary数量：%@",difary);
//
//    [self downLoadImageFromURL:difary];
//}
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//  
//}



/*        //通过正则表达式 来缓存（貌似不可以）
//获取web里的所有的img url
- (NSString *)createImgArrayJavaScript{
    NSString *js = @"var imgArray = document.getElementsByTagName('img'); var imgstr = ''; function f(){ for(var i = 0; i < imgArray.length; i++){ imgstr += imgArray[i].src;imgstr += ';';} return imgstr; } f();";
    return js;
}

//返回web img图片的数量
- (NSString *)createGetImgNumJavaScript{
    NSString *js = @"var imgArray = document.getElementsByTagName('img');function f(){ var num=imgArray.length;return num;} f();";
    return js;
}




- (void)downLoadImageFromURL:(NSArray* )imageUrlArray
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < imageUrlArray.count; i++)
    {
        NSString *imageUrl = [imageUrlArray objectAtIndex:i];
        NSString *key = [imageUrl MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        NSURL *imageURL = [NSURL URLWithString:imageUrl];
        NSString *index = [NSString stringWithFormat:@"%d", i];
        
        if (data) {
           NSString *strinsrg =  [self.webView stringByEvaluatingJavaScriptFromString:[self createSetImageUrlJavaScript:index imgUrl:key]];
            NSLog(@"多少的：%@",strinsrg);
        }else{
            dispatch_group_async(group, queue, ^{
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                if (data != nil) {
                    [FTWCache setObject:data forKey:key];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                       NSString *strs =  [self.webView stringByEvaluatingJavaScriptFromString:[self createSetImageUrlJavaScript:index imgUrl:key]];
                        NSLog(@"image i %d",i);
                        NSLog(@"strs:  %@",strs);

                    });
                    
                }
            });
            
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //这里是所有图片下载完成后执行的操作。
    });
    
//    dispatch_release(group);
}

//设置下载完成的图片到web img
- (NSString *)createSetImageUrlJavaScript:(NSString *) index imgUrl:(NSString *) url{
    NSData *imageData = [FTWCache objectForKey:url];
    UIImage  *image = [UIImage imageWithData:imageData];
    int imageWidth = 300;
    int imageHeight = image.size.height*300.0f/image.size.width;
    NSString *js = [NSString stringWithFormat:@"var imgArray = document.getElementsByTagName('img'); imgArray[%@].src=\"%@\"; imgArray[%@].width=\"%d\";imgArray[%@].height=\"%d\" ;" , index, url, index,imageWidth,index,imageHeight];
    return js;
}




//- (void) getImageUrlArray:(NSString*) content
//{
//    DDLOG_CURRENT_METHOD;
//    NSString *urlPattern = @"<img[^>]+?src=[\"']?([^>'\"]+)[\"']?";
//    NSError *error = [NSError new];
//    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlPattern options:NSRegularExpressionCaseInsensitive error:&error ];
//    
//    //match 这块内容非常强大
//    NSUInteger count =[regex numberOfMatchesInString:content options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [content length])];//匹配到的次数
//    if(count > 0){
//        NSArray* matches = [regex matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
//        
//        for (NSTextCheckingResult *match in matches) {
//            
//            NSInteger count = [match numberOfRanges];//匹配项
//            for(NSInteger index = 0;index < count;index++){
//                NSRange halfRange = [match rangeAtIndex:index];
//                if (index == 1) {
//                    [listImage addObject:[content substringWithRange:halfRange]];
//                }
//            }
//        }//遍历后可以看到三个range，1、为整体。2、为([\\w-]+\\.)匹配到的内容。3、(/?[\\w./?%&=-]*)匹配到的内容
//    }
//    
//}
*/
 
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}


@end
