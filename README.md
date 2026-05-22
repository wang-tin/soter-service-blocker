
# SoterService拦截器

## 作者
王听

## 功能
拦截 com.chunqiunativecheck 对 SoterService 的调用

## 特点
- 自动检查 /system_ext/app/SoterService 文件夹
- 拦截 SoterService.apk 文件调用
- 拦截 SoterService.vdex 文件调用
- 不使用 hook 和 Xposed 技术
- 通过系统属性和权限限制实现拦截

## 免责声明
本模块仅供学习和研究使用。使用本模块所产生的一切后果由使用者自行承担，作者不承担任何责任。请遵守当地法律法规，不要将本模块用于非法用途。

## 安装方法
1. 在 Magisk Manager 中刷入本模块 zip 文件
2. 重启设备
3. 模块将自动生效

## 卸载方法
在 Magisk Manager 中卸载本模块即可
