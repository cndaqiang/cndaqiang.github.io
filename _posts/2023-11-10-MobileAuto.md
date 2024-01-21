---
layout: post
title:  "Android/IOS移动平台自动化脚本(基于AirTest)"
date:   2023-11-10 23:47:00 +0800
categories: AirTest Android IOS
tags: AirTest
author: cndaqiang
mathjax: true
---
* content
{:toc}







## 备注
- 适配王者荣耀的脚本: 单人/组队模式/熟练度/金币/礼物/营地. 支持Android/Iphone<br>[AirTest_MobileAuto_WZRY@cndaqiang](https://github.com/cndaqiang/AirTest_MobileAuto_WZRY)
- 致谢大量参考了[WZRY_AirtestIDE@XRSec](https://github.com/XRSec/WZRY_AirtestIDE)项目,是我学习AirTest脚本的主要参考.


## 控制端运行方式
测试稳定平台:Windows/MacOS/Linux(x86)/Linux(aarch64)

### 环境
```bash
python -m pip  install -i https://pypi.tuna.tsinghua.edu.cn/simple  airtest,pathos
```
Linux
```bash
sudo apt-get install libgl1-mesa-glx
```
Linux(ARM)
```bash
cndaqiang@oracle:~/.local/lib/python3.10/site-packages/airtest/core/android/static/adb/linux$ mv adb adb.bak
cndaqiang@oracle:~/.local/lib/python3.10/site-packages/airtest/core/android/static/adb/linux$ ln -s /usr/bin/adb .
```
Mac
```bash
chmod +x /Users/cndaqiang/anaconda3/lib/python3.11/site-packages/airtest/core/android/static/adb/mac/adb
```

### 代码修改
#### monkey
mac/linux都会报错 airtest使用monkey控制安卓的命令 `monkey -p com.tencent.tmgp.sgame -c android.intent.category.LAUNCHER 1`,#会报错
```
** SYS_KEYS has no physical keys but with factor 2.0%.
airtest.core.error.AdbError: stdout[b'  bash arg: -p\n  bash arg: com.tencent.tmgp.sgame\n  bash arg: -c\n  bash arg: android.intent.category.LAUNCHER\n  bash arg: 1\n'] stderr[b'args: [-p, com.tencent.tmgp.sgame, -c, android.intent.category.LAUNCHER, 1]\n arg: "-p"\n arg: "com.tencent.tmgp.sgame"\n arg: "-c"\n arg: "android.intent.category.LAUNCHER"\n arg: "1"\ndata="com.tencent.tmgp.sgame"\ndata="android.intent.category.LAUNCHER"\n** SYS_KEYS has no physical keys but with factor 2.0%.\n']
```

添加`--pct-syskeys 0`

修改`/home/cndaqiang/.local/lib/python3.10/site-packages/airtest/core/android/adb.py`
```
1387         if not activity:
1388             self.shell(['monkey --pct-syskeys 0', '-p', package, '-c', 'android.intent.category.LAUNCHER', '1'])
1389         else:
1390             self.shell(['am', 'start', '-n', '%s/%s.%s' % (package, package, activity)])
```

#### mac远程控制adb时,有概率无法获得屏幕截图
- 报错`[15:59:29][WARNING]<airtest.core.api> Screen is None, may be locked`,程序会退出,但是在多进程执行时，单进程报错只会卡住,不会全部停止
- 方案，尝试过修改`airtest,requests`的代码和设置`airtest.core.settings.Settings.FIND_TIMEOUT`, 最后干脆重写(套壳)了一层airtest的函数

```python
def exists(*args, **kwargs):
    try:
        result=exists_o(*args, **kwargs)
    except:
        print("cndaqiang: exists失败")
        result=False
    return result
```

### 执行AirTest脚本
```bash
python -u object.py 2>&1 | tee result
```
n个进程模式
```bash
python -u object.py -n 2>&1 | tee result
```


## 客户端
模拟器
- Windows Bluestack 多开adb都可以,还兼容hyper-v(Pie 64bit).  不兼容hyper-v的**Nougat模式**更省电，适合不用开wsl的笔记本,而且adb的端口也不会变
- Linux使用[remote-android](https://github.com/remote-android/),支持arm服务器
- Mac 未发现合适的

移动设备
- Android
- IOS(测试通过 15.8,16.2)

### Windows Bluestack
默认安装即可,从多开的平台进入
`object.py`中有重启Bluestack的命令


### remote-android虚拟机(Linux(aarch64))
原则上x86/Arm的Docker都可以运行. 我仅在甲骨文的服务器上完成测试,环境:`Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-84-generic aarch64)`
`object.py`中有重启容器的命令

#### 搭建
服务器
```bash
apt install linux-modules-extra-`uname -r`
#这两个命令，每次开机后都要输入一次，不然contain开机后，adb各种报错，如Binder driver could not be opened.  Terminating.
#添加到开机启动,服务器没有重启，那么不需要重新执行 
modprobe binder_linux devices="binder,hwbinder,vndbinder"
modprobe ashmem_linux
```
创建环境,安装软件
```bash
mkdir -p /home/cndaqiang/builddocker/redroid/
cd /home/cndaqiang/builddocker/redroid/
docker run -itd \
  --memory-swappiness=0 \
  --privileged --pull always \
  -v /home/cndaqiang/builddocker/redroid/8arm:/data \
  -p 5555:5555 \
  redroid/redroid:8.1.0-arm64 \
  androidboot.hardware=mt6891 ro.secure=0 ro.boot.hwc=GLOBAL    ro.ril.oem.imei=861503068361145 ro.ril.oem.imei1=861503068361145 ro.ril.oem.imei2=861503068361148 ro.ril.miui.imei0=861503068361148 ro.product.manufacturer=Xiaomi ro.build.product=chopin \
  androidboot.redroid_width=960 \
  androidboot.redroid_height=540 \
  androidboot.redroid_dpi=160 \
  androidboot.redroid_fps=5 \
  redroid.gpu.mode=guest
#安装一个简单的桌面,然后卸载所有不需要的软件,安装刷机软件入WZRY
root@oracle:/home/cndaqiang/builddocker/redroid# adb install /home/cndaqiang/jijianzhuomian.apk
```
多开,可以使用相同的软件数据,不同的缓存空间
```bash
N=2
port=5565
rm -rf 8arm$N
mkdir -p 8arm$N/data/com.tencent.tmgp.sgame/databases
chown -R cndaqiang:cndaqiang  8arm$N
chmod -R 771 8arm$N
#data文件夹以上是cndaqiang,以下是tencent
chmod -R 700 8arm$N/data/com.tencent.tmgp.sgame
chmod 771 8arm$N/data/com.tencent.tmgp.sgame/databases
#每个程序应该是不同的uid,根据王者目录显示uid确定
chown -R 10065:10065 8arm$N/data/com.tencent.tmgp.sgame
#缺点是安卓容器，不能同时开机,这样并不怎么占用空间
#为了多开刷友情币足够了，如果有系统更新，应该不行

docker run -itd \
  --memory-swappiness=0 \
  --privileged --pull always \
  --name androidcontain$N \
  -v /home/cndaqiang/builddocker/redroid/8arm:/data \
  -v /home/cndaqiang/builddocker/redroid/8arm$N/data/com.tencent.tmgp.sgame/databases:/data/data/com.tencent.tmgp.sgame/databases \
  -p $port:5555 \
  redroid/redroid:8.1.0-arm64 \
  androidboot.hardware=mt6891 ro.secure=0 ro.boot.hwc=GLOBAL    ro.ril.oem.imei=861503068361145 ro.ril.oem.imei1=861503068361145 ro.ril.oem.imei2=861503068361148 ro.ril.miui.imei0=861503068361148 ro.product.manufacturer=Xiaomi ro.build.product=chopin \
  androidboot.redroid_width=960 \
  androidboot.redroid_height=540 \
  androidboot.redroid_dpi=160 \
  androidboot.redroid_fps=5 \
  redroid.gpu.mode=guest 
```


### Android
#### 备注
* scrcpy 真好用
```bash
brew install scrcpy
brew install android-platform-tools
adb connect -s 192.168.192.10:5565
scrcpy -s 192.168.192.10:5565
```

#### 开发者模式
开发者模式打开,开启无线ADB调试,老版本安卓可有线ADB后开无线ADB
```bash
(base) cndaqiang@macmini mac$ pwd
/Applications/AirtestIDE.app/Contents/Resources/plugins/firebase_plugin/tool/copy_app/airtest/core/android/static/adb/mac
(base) cndaqiang@macmini mac$ ./adb devices
List of devices attached
8553e6ac	device

(base) cndaqiang@macmini mac$ ./adb tcpip 5555
adb server version (40) doesn't match this client (39); killing...
* daemon started successfully *

restarting in TCP mode port: 5555
```

### IOS
#### 备注
使用同一个WDA源码编译时
* 发现Ipad mini6(IOS15.6.1)和Iphone11(16.2) 可以不依赖Xcode就能从手机上打开，然后通过wifiIP控制
* Iphone SE1(IOS14.2) 无法独立打开,需要xcode的Test模式,或者下面介绍的` tidevice xctest -B com.cndaqiang.WebDriverAgentRunner.xctrunner`
*  Iphone SE1(IOS15.2)升级到15.2后,虽然安装后,可以手机独立打开,但是无法通过wifiIP:8100访问. 还是只能插数据线后xcode/tidevice. 暂时放弃找原因了
* 由于系统版本低，在虚拟机中给ip11编译安装的
* 换设备编译时,建议先清空一下编译环境,不然会有各种奇怪问题
* 目前仅找到AirTest能够控制安装了WDA的IOS设备

#### 使用Xcode 安装WebDriverAgent(WDA)
* 安装Xcode,注意Xcode有MacOS版本要求和IOS版本要求,下载复合自己的版本
* 注册个人免费版账户
![image](/uploads/2023/11/2418819-20231108221359822-189765304.png)

下载WebDriverAgen代码. 注意,不同版本的代码对机器兼容不同,能编译安装不一定能远程控制. 这里备份了两个能用的版本, 直接 git clone
* [ipad mini6, iphone11都是直接编译就通过了](https://github.com/cndaqiang/WebDriverAgent_ForIp11_Ipadmini6)
* [se的设置使用/iOS-Tagent可以正常启动控制,也支持ipad mini6,支持iphone8模拟器，不支持iphone11模拟器...](https://github.com/cndaqiang/iOS-Tagent_ForIpSE1)

用xcode打开
```bash
(base) cndaqiang@macmini git$ git clone git@github.com:cndaqiang/iOS-Tagent_ForIpSE1.git
Cloning into 'iOS-Tagent_ForIpSE1'...
remote: Enumerating objects: 24556, done.
remote: Counting objects: 100% (1163/1163), done.
remote: Compressing objects: 100% (82/82), done.
remote: Total 24556 (delta 1125), reused 1082 (delta 1081), pack-reused 23393
Receiving objects: 100% (24556/24556), 34.09 MiB | 5.21 MiB/s, done.
Resolving deltas: 100% (11560/11560), done.
(base) cndaqiang@macmini git$ cd iOS-Tagent_ForIpSE1/
(base) cndaqiang@macmini iOS-Tagent_ForIpSE1$ open -a xcode WebDriverAgent.xcodeproj
```
**就只用改下面这两个地方**,别的教程里说的太多了,没必要
设置个人开发者账户.

![image](/uploads/2023/11/2418819-20231108222025551-1449346653.png)
使用自己的包名，注意个人开发者每周使用的包名有限制的，测试时就一致用一个
![image](/uploads/2023/11/2418819-20231108222109368-1590133600.png)
这里这样选择，设备可以用真机，也可以用模拟器
![image](/uploads/2023/11/2418819-20231108222214936-1417344298.png)

Product>Test
![image](/uploads/2023/11/2418819-20231108222610873-1680378447.png)

提示这个没事，在手机上允许就可以了,再点击test
![image](/uploads/2023/11/2418819-20231108222539553-898794788.png)

把xcode地步拉起，可以看到运行信息
![image](/uploads/2023/11/2418819-20231108222905035-1293652009.png)

**打开提示的网址`http://169.254.235.186:8100`可以看到启动成功了**
也可以映射到本地`127.0.0.1:8123`，更多方法很多帖子里都有
```
brew install usbmux
iproxy 8123 8100
```

#### 没有Xcode时 安装WebDriverAgent(WDA)
**提前准备WDA.ipa**,获取途径
- 越狱后用Filza提取ipa, 提取目录`/var/contain.../Bun.../App/appname`
- 虚拟机Xcode, build>找到build目录>复制出来>命名为Payload>压缩>改名为XXX.ipa
![](/uploads/2023/11/1700204740958.jpg)
![](/uploads/2023/11/1700205066173.jpg)

**进行签名**
- 如果上一步的ipa是制定设备编译的,安装在该设备时,距离编译结束的7天内是可以的. 
- 因为不想再重新编译和使用xcode. 这里认为上一步获得的ipa已经签名过期
- 使用i4助手的ipa签名功能,手机连接电脑，登录appleID进行签名
![](/uploads/2023/11/1700205318354.jpg)

**安装签完名的APP**,安装失败多是没有正确签名,使用sideload等自签名程序,安装后都打不开
- i4的APP管理功能可以安装
- `tidevice`安装 `tidevice install /Users/cndaqiang/Downloads/i4ToolsDownloads/SignIpa/13.4.Framework_AnyIOS.WDA.ipa`


#### tidevice
不同IOS设备需要不同的Xcode编译,我的工作环境版本太低,在虚拟机中编译安装的WDA,在工作环境可以使用tidevice启动设备的WDA服务.

高阶用法见:[taobao-iphone-device](https://github.com/alibaba/taobao-iphone-device)

```bash
pip install tidevice
```

* 就一条命令,他提示的`ServerURLHere->http://169.254.148.222:8100`和xcode一样,也不会变化,可以填到脚本中去
* 在AirTest可以使用`http://169.254.148.222:810`或`http+usbmux://***MyIphoneSEID_cndaqiang***`访问
```bash
(base) cndaqiang@macmini ~$ tidevice wdaproxy -B  com.cndaqiang.WebDriverAgentRunner.xctrunner
[I 231110 22:46:45 _wdaproxy:128] [***MyIphoneSEID_cndaqiang***] WDA check every 30.0 seconds
[D 231110 22:46:45 _wdaproxy:134] [***MyIphoneSEID_cndaqiang***] launch WDA
[D 231110 22:46:45 _wdaproxy:58] [***MyIphoneSEID_cndaqiang***] request error: ('Connection aborted.', MuxReplyError(<UsbmuxReplyCode.ConnectionRefused: 3>))
[I 231110 22:46:45 _device:972] BundleID: com.cndaqiang.WebDriverAgentRunner.xctrunner
[I 231110 22:46:45 _device:999] ProductVersion: 15.8
[I 231110 22:46:45 _device:1000] UDID: ***MyIphoneSEID_cndaqiang***
[D 231110 22:46:46 _wdaproxy:58] [***MyIphoneSEID_cndaqiang***] request error: ('Connection aborted.', MuxReplyError(<UsbmuxReplyCode.ConnectionRefused: 3>))
[I 231110 22:46:46 _device:842] SignIdentity: 'Apple Development: chendq@aliyun.com (J74WNV5Q32)'
[I 231110 22:46:46 _device:848] CFBundleExecutable: WebDriverAgentRunner-Runner
[I 231110 22:46:46 _device:916] Launch 'com.cndaqiang.WebDriverAgentRunner.xctrunner' pid: 536
[D 231110 22:46:47 _wdaproxy:58] [***MyIphoneSEID_cndaqiang***] request error: ('Connection aborted.', MuxReplyError(<UsbmuxReplyCode.ConnectionRefused: 3>))
[I 231110 22:46:47 _device:1048] Test runner ready detected
[I 231110 22:46:47 _device:1040] Start execute test plan with IDE version: 29
[D 231110 22:46:48 _wdaproxy:58] [***MyIphoneSEID_cndaqiang***] request error: ('Connection aborted.', MuxReplyError(<UsbmuxReplyCode.ConnectionRefused: 3>))
[I 231110 22:46:49 _device:933] 2023-11-10 22:46:46.851840+0800 WebDriverAgentRunner-Runner[536:43854] ServerURLHere->http://169.254.148.222:8100<-ServerURLHere
[I 231110 22:46:49 _device:934] WebDriverAgent start successfully
```


##### tidevice安装APP签名错误解释
```
[E 231117 14:02:49 _installation:55] Failed to verify code signature of /var/installd/Library/Caches/com.apple.mobile.installd.staging/temp.gurRaK/extracted/Payload/WebDriverAgentRunner-Runner.app : 0xe8008018 (The identity used to sign the executable is no longer valid.)
```
签名不再有效**sign the executable is no longer valid**, 安装时没有选择个人签名就build了.

```
[E 231117 14:11:56 _installation:55] Failed to verify code signature of /var/installd/Library/Caches/com.apple.mobile.installd.staging/temp.uok9qe/extracted/Payload/WebDriverAgentRunner-Runner.app : 0xe8008015 (A valid provisioning profile for this executable was not found.)
```
**A valid provisioning profile for this executable was not found**
因为该app的APPLE个人签名，不包含此设备



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
