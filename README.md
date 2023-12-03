# vmess前置落地sk5代理
---

##  一键快速配置二级代理脚本可配置多个出站（vmess+ws前置）
```
wget -N --no-check-certificate https://github.com/taotao1058/vmess/raw/main/duos && bash duos
```



---
###  自用静态格式（vmess+ws前置）

```
wget -N --no-check-certificate https://github.com/taotao1058/vmess/raw/main/ziyong && bash ziyong
```

---

###  SS前置

```
wget -N --no-check-certificate https://github.com/taotao1058/vmess/raw/main/SS && bash SS
```

---

###  多端口对应多个出站（vmess+ws前置）

```
wget -N --no-check-certificate https://github.com/taotao1058/vmess/raw/main/duo && bash duo
```
---

###  3x-ui安装脚本

```
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```


####  3x-ui自定义出站模板



```
[
  {
    "protocol": "socks",
    "settings": {
      "servers": [
        {
          "address": "地址",
          "port": 端口,
          "users": [
            {
              "user": "用户名",
              "pass": "密码"
            }
          ]
        }
      ]
    }
  },
  {
    "tag": "blocked",
    "protocol": "blackhole",
    "settings": {}
  }
]
```


---

