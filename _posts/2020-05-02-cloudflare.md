---
layout: post
title:  "使用cloudflare加速博客访问/免费搭建谷歌镜像"
date:   2020-05-02 08:39:00 +0800
categories: web
tags:  cdn web Google
author: cndaqiang
mathjax: true
---
* content
{:toc}




## 参考
[使用 Cloudflare Workers™ 制作镜像站，可访问谷歌@何先生](https://umrhe.com/cloudflare-workers-to-google.html)

## 结果:测速对比
```
wget https://blog.cndaqiang.workers.dev/uploads/2020/04/coffee.jpg
wget https://cndaqiang.github.io/uploads/2020/04/coffee.jpg
wget https://cndaqiang.gitee.io/uploads/2020/04/coffee.jpg
```
**国内访问速度: `gitee = 5*cloudfare = 50*GithubPage`**
- cloudfare
```
2020-05-02 08:35:44 (419 KB/s) - ‘coffee.jpg.1’ saved [3248748/3248748]
```
- Github Page
```
2020-05-02 08:37:34 (36.8 KB/s) - ‘coffee.jpg.2’ saved [3248748/3248748]
```
- gitee
```
2020-05-02 08:40:33 (2.13 MB/s) - ‘coffee.jpg.3’ saved [3248748/3248748]
```
站长工具测试
![](/uploads/2020/05/blogspeed1.png)

## 操作
### 注册
注册[https://dash.cloudflare.com/](https://dash.cloudflare.com/)
### 创建Workers
![](/uploads/2020/05/cloudfare.jpg)
创建一个worker
![](/uploads/2020/05/cloudfare2.jpg)
### 填入脚本
- 谷歌镜像脚本

```
// 你要镜像的网站.
const upstream = 'www.google.com'

// 镜像网站的目录，比如你想镜像某个网站的二级目录则填写二级目录的目录名，镜像 google 用不到，默认即可.
const upstream_path = '/'

// 镜像站是否有手机访问专用网址，没有则填一样的.
const upstream_mobile = 'www.google.com'

// 屏蔽国家和地区.
const blocked_region = ['KP', 'SY', 'PK', 'CU']

// 屏蔽 IP 地址.
const blocked_ip_address = ['0.0.0.0', '127.0.0.1']

// 镜像站是否开启 HTTPS.
const https = true

// 文本替换.
const replace_dict = {
    '$upstream': '$custom_domain',
    '//google.com': ''
}

// 以下保持默认，不要动
addEventListener('fetch', event => {
    event.respondWith(fetchAndApply(event.request));
})

async function fetchAndApply(request) {

    const region = request.headers.get('cf-ipcountry').toUpperCase();
    const ip_address = request.headers.get('cf-connecting-ip');
    const user_agent = request.headers.get('user-agent');

    let response = null;
    let url = new URL(request.url);
    let url_hostname = url.hostname;

    if (https == true) {
        url.protocol = 'https:';
    } else {
        url.protocol = 'http:';
    }

    if (await device_status(user_agent)) {
        var upstream_domain = upstream;
    } else {
        var upstream_domain = upstream_mobile;
    }

    url.host = upstream_domain;
    if (url.pathname == '/') {
        url.pathname = upstream_path;
    } else {
        url.pathname = upstream_path + url.pathname;
    }

    if (blocked_region.includes(region)) {
        response = new Response('Access denied: WorkersProxy is not available in your region yet.', {
            status: 403
        });
    } else if (blocked_ip_address.includes(ip_address)) {
        response = new Response('Access denied: Your IP address is blocked by WorkersProxy.', {
            status: 403
        });
    } else {
        let method = request.method;
        let request_headers = request.headers;
        let new_request_headers = new Headers(request_headers);

        new_request_headers.set('Host', url.hostname);
        new_request_headers.set('Referer', url.hostname);

        let original_response = await fetch(url.href, {
            method: method,
            headers: new_request_headers
        })

        let original_response_clone = original_response.clone();
        let original_text = null;
        let response_headers = original_response.headers;
        let new_response_headers = new Headers(response_headers);
        let status = original_response.status;

        new_response_headers.set('access-control-allow-origin', '*');
        new_response_headers.set('access-control-allow-credentials', true);
        new_response_headers.delete('content-security-policy');
        new_response_headers.delete('content-security-policy-report-only');
        new_response_headers.delete('clear-site-data');

        const content_type = new_response_headers.get('content-type');
        if (content_type.includes('text/html') && content_type.includes('UTF-8')) {
            original_text = await replace_response_text(original_response_clone, upstream_domain, url_hostname);
        } else {
            original_text = original_response_clone.body
        }

        response = new Response(original_text, {
            status,
            headers: new_response_headers
        })
    }
    return response;
}

async function replace_response_text(response, upstream_domain, host_name) {
    let text = await response.text()

    var i, j;
    for (i in replace_dict) {
        j = replace_dict[i]
        if (i == '$upstream') {
            i = upstream_domain
        } else if (i == '$custom_domain') {
            i = host_name
        }

        if (j == '$upstream') {
            j = upstream_domain
        } else if (j == '$custom_domain') {
            j = host_name
        }

        let re = new RegExp(i, 'g')
        text = text.replace(re, j);
    }
    return text;
}


async function device_status(user_agent_info) {
    var agents = ["Android", "iPhone", "SymbianOS", "Windows Phone", "iPad", "iPod"];
    var flag = true;
    for (var v = 0; v < agents.length; v++) {
        if (user_agent_info.indexOf(agents[v]) > 0) {
            flag = false;
            break;
        }
    }
    return flag;
}
```

- 博客加速脚本
把谷歌镜像脚本开头替换为即可. 博客有的页面第一次打开偶尔会出现页面乱的情况，刷新一下就好了

```
// 你要镜像的网站.
const upstream = 'cndaqiang.github.io'

// 镜像网站的目录，比如你想镜像某个网站的二级目录则填写二级目录的目录名，镜像 google 用不到，默认即可.
const upstream_path = '/'

// 镜像站是否有手机访问专用网址，没有则填一样的.
const upstream_mobile = 'cndaqiang.github.io'

// 屏蔽国家和地区.
const blocked_region = ['KP', 'SY', 'PK', 'CU']

// 屏蔽 IP 地址.
const blocked_ip_address = ['0.0.0.0', '127.0.0.1']

// 镜像站是否开启 HTTPS.
const https = true

// 文本替换.
const replace_dict = {
    '$upstream': '$custom_domain',
    '//cndaqiang.github.io': ''
}
```

### 部署访问
每天有免费100,000次的请求，个人足够了


## 后续
youtube的镜像卡的不行<br>
谷歌学术异常流量问题<br>
谷歌的镜像没有问题,手机测试通过<br>
![](/uploads/2020/05/1520248476.jpg)
<br>
应该可以造成图床cdn加速一样的,在githuapage里面存上图片，然后用cloudflare加速



------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
