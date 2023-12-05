# vmess前置落地sk5代理（适用于Ubuntu系统）
---

##  一键脚本快速搭建
```
wget -N --no-check-certificate https://github.com/taotao1058/vmess/raw/main/xinduo && bash xinduo
```

#####  特点：快速批量搭建二级代理
#####        可管理节点新增和删除
#####        小白可用 操作简单

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

