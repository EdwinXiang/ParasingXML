//
//  ViewController.m
//  测试
//
//  Created by Edwin on 16/3/7.
//  Copyright © 2016年 EdwinXiang. All rights reserved.
//

#import "ViewController.h"
#import "ZipArchive.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //读取沙盒资源文件，并且解压zip包
    [self readResourceFromSanbox];
    
    //读取xml文件内容
    [self readXmlContent];
}
-(void)readXmlContent {
    NSString *sanboxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *path = [[NSString alloc]initWithFormat:@"%@/示例频道包",sanboxPath];
    NSString *channelConfigxmlPath = [path stringByAppendingPathComponent:@"channelConfig.xml"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:channelConfigxmlPath];
    //修改数据模型路径
    [self parasingXmlData:data withKeyXML:@"//TrackingData//media"];
    
}

//解析xml文件内容
-(void)parasingXmlData:(NSData *)data withKeyXML:(NSString *)kXML{
    DDXMLDocument *doc = [[DDXMLDocument alloc]initWithData:data options:0 error:nil];
    //解析
    //修改media文件路径
    NSArray *items = [doc nodesForXPath:kXML error:nil];
    NSLog(@"items = %@",items);
    for (int i = 0; i<items.count; i++) {
        DDXMLElement *element = items[i];
        DDXMLNode *auser = [element attributeForName:@"name"];
        NSString *str = auser.stringValue;
        NSLog(@"str == %@",str);
        if ([str hasPrefix:@"http"] || [str hasPrefix:@"https"]) {
            NSArray *arr = [str componentsSeparatedByString:@"/"];
            NSString *fileName = [arr lastObject];
           NSString *mediaName = [self downLoadWithUrl:str withFileName:fileName];
            NSLog(@"media = %@",mediaName);
            //分割数组
            NSArray *mediaArr = [mediaName componentsSeparatedByString:@"/"];
            NSLog(@"数组:%@",mediaArr);
            //拼接字符串
            NSString *resultStr = [NSString stringWithFormat:@"assets/media/%@",mediaArr.lastObject];
            [auser setStringValue:[NSString stringWithFormat:@"%@",resultStr]];
        }
        
    }
    
    //修改识别图路径
    //解析
    NSArray *Iconitems = [doc nodesForXPath:@"//TrackingData//dataset" error:nil];
    NSLog(@"itemscount = %ld",(unsigned long)Iconitems.count);
    for (int i = 0; i<Iconitems.count; i++) {
        DDXMLElement *element = Iconitems[i];
        DDXMLNode *auser = [element attributeForName:@"name"];
        NSString *str = auser.stringValue;
        NSLog(@"str == %@",auser);
        if ([str hasPrefix:@"http"] || [str hasPrefix:@"https"]) {
            NSArray *arr = [str componentsSeparatedByString:@"/"];
            NSString *fileName = [arr lastObject];
            NSString *datasetName = [self downLoadWithUrl:str withFileName:fileName];
            NSLog(@"media = %@",datasetName);
            //分割数组
            NSArray *datasetArr = [datasetName componentsSeparatedByString:@"/"];
            NSLog(@"数组:%@",datasetArr);
            //拼接字符串
            NSString *resultStr = [NSString stringWithFormat:@"assets/dataset/%@",datasetArr.lastObject];
            [auser setStringValue:[NSString stringWithFormat:@"%@",resultStr]];
        }
    }
    
    //保存到沙盒目录下
    NSString *path =[[NSString alloc]initWithFormat:@"%@/changeXmlData.xml", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0]];
    NSString *result=[[NSString alloc]initWithFormat:@"%@",doc];
    //写入数据
    [result writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSString *)downLoadWithUrl:(NSString *)urlStr withFileName:(NSString *)fileName {
    NSString *mediaName = nil;
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    //    // 3. 使用连接对象发送异步请求
    NSURLResponse *response = [[NSURLResponse alloc]init];
    NSData *data = (NSData *)[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if (data != nil) {
        NSLog(@"下载资源成功");
        //下载文件路径
        NSString *path =[[NSString alloc]initWithFormat:@"%@/示例频道包/assets/media", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0]];
        //下载过后的文件名
        NSString *mediapath = [path stringByAppendingPathComponent:fileName];
        //数据写入
        [data writeToFile:mediapath options:NSDataWritingAtomic error:nil];
        mediaName = mediapath;
    }
    return mediaName;
}

-(void)readResourceFromSanbox{
    
    NSString *sanboxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSLog(@"document = %@",sanboxPath);
    //修改文件名
//    [self changeFileName:sanboxPath];
    //获取到zip包的包名
    NSString *zipPath = [sanboxPath stringByAppendingPathComponent:[NSString stringWithFormat:@"channelResource.zip"]];
    
    NSError *error = nil;
    if(!error)
    {
        if(!error)
        {
            ZipArchive *zip = [[ZipArchive alloc]init];
             //3. 解压缩已下载的zip文件
            if ([zip UnzipOpenFile: zipPath]) {
                // 2
                BOOL ret = [zip UnzipFileTo: sanboxPath overWrite: YES];
                if (NO == ret){}
                [zip UnzipCloseFile];
            }
        }
        else
        {
            NSLog(@"Error saving file %@",[error localizedDescription]);
        }
    }
    else
    {
        NSLog(@"Error downloading zip file: %@", [error localizedDescription]);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
