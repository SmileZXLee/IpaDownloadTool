# IpaDownloadTool
<div align="center">
  <img src="http://www.zxlee.cn/IpaDownloadToolLogo.png" width="150" height="150"/>
  <h2 align="center">IPA提取器</h2>
</div> 

[![release](https://img.shields.io/github/v/release/SmileZXLee/IpaDownloadTool?style=flat)](https://github.com/SmileZXLee/IpaDownloadTool/releases)
[![Support](https://img.shields.io/badge/support-iOS%209.0%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/SmileZXLee/IpaDownloadTool/blob/master/LICENSE)&nbsp;
### Release版本(当前版本v2.0.1)
* [点击此处直接下载最新IPA提取器安装包](https://static.ifafu.cn/IpaDownloadTool.ipa)
### 反馈qq群：[790460711](https://jq.qq.com/?_wv=1027&k=vU2fKZZH)
### 功能
* 此工具用来快捷下载/储存第三方来源的ipa
* 支持蒲公英、fir下载页面拦截ipa地址、ipa下载
* 支持其他网站自定义h5页面拦截ipa地址、ipa下载
* 支持网址&二维码扫描方式录入网址
* 支持下载历史记录列表，可以本地储存任意数量的ipa，无需担心下载页面失效导致ipa丢失
* 支持ipa本地下载，分享给朋友或隔空投送发送至电脑
* 不支持App Store ipa下载
### 使用须知
“IPA提取器”是一个用于提取第三方网页中的ipa并进行测试的应用程序，仅限用于学习交流，不得将“IPA提取器”或其衍生版本用于任何违法违规的用途，不得用于提取任何违法违规的ipa！由于违规使用导致的任何后果开发者不承担任何责任！
### 预览
操作演示 | 应用详情   
-|-
![](http://www.zxlee.cn/IpaDownloadToolDemo.gif) | ![](https://upload-images.jianshu.io/upload_images/17729343-ab4b953d0a0696a4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) |

### 项目中使用的第三方:
* [ALToastView](https://github.com/alexleutgoeb/ALToastView)
* [SGQRCode](https://github.com/kingsic/SGQRCode)
* [BackButtonHandler](https://github.com/onegray/UIViewController-BackButtonHandler)
* [NJKWebViewProgress](https://github.com/ninjinkun/NJKWebViewProgress)
* [ZXTableView](https://github.com/SmileZXLee/ZXTableView)
* [ZXDataHandle](https://github.com/SmileZXLee/ZXDataHandle)
### 更新日志
#### 2022.10.18(v2.0.1)
1.【新增】支持直接下载网页中的ipa文件。  
2.【新增】IPA提取器主页添加网页前进、后退、重新加载操作。  
3.【新增】ipa提取历史支持根据时间或文件名排序。  
4.【新增】网页浏览历史页面支持编辑网页标题。  
5.【新增】支持数据导入导出。  
6.【修复】当网址中包含中文时，网页加载失败的问题。  
7.【修复】plist文件下载失败时，应用闪退的问题。  
8.【修复】网页历史记录中网站logo不展示的问题。  
9.【修复】横屏时网页加载进度条错位的问题。  
10.【修复】修复在iPad中，点击应用详情中的：点击分享/重新下载项时闪退的问题。  
11.【优化】提取ipa信息成功后可直接跳转到详情。  
12.【优化】删除下载中断的文件。  
13.【优化】ipa提取规则&细节。  
14.【优化】APP重新打开自动加载最近一次加载的网页。  
15.【优化】分享的文件名显示原名，而非显示md5之后的密文。
#### 2022.09.27(v1.0.3)
1.修复在iOS15+系统中，导航栏变黑的问题；  
2.修复在iOS15+系统中，tableView顶部有一段间隙的问题；  
3.修复在某些情况下，网页历史记录中网址记录不全的问题；  
4.已下载页面支持侧滑删除所下载的ipa；  
5.添加版本号相关信息
#### 2021.01.16(v1.0.2)
1.支持蒲公英超级签名(eucoming.com)及类似平台，新增对安装描述文件的检测和提示；  
2.新增打开App自动从剪切板读取并询问是否加载；  
3.支持修改本地应用名称，在ipa解析历史列表和下载列表中添加版本号的展示；  
4.支持长按【网页】按钮查看访问的网页历史，单击打开对应网页；  
5.体验优化。
#### 2019.11.14(v1.0.1)
修复在iOS13中重签名之后无法正常下载ipa的问题，感谢[@ningQAQ](https://github.com/ningQAQ)的帮助。
