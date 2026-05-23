
# SoterService拦截器

## 作者
王听

## 功能
强力拦截 SoterService，阻止任何应用（包括 com.chunqiunativecheck）调用它

## 特点
- 强力多重拦截方案
- 直接禁用 SoterService 应用/组件
- 不使用 hook 和 Xposed 技术
- 通过系统命令、权限限制、mount 隐藏等方式实现

## 拦截方法
1. **pm disable**：直接禁用 SoterService 应用和组件
2. **权限限制**：chmod 000 阻止访问相关文件
3. **系统属性**：禁用 soter 相关系统属性
4. **Mount 隐藏**：尝试用 mount bind 隐藏文件夹

## 免责声明
本模块仅供学习和研究使用。使用本模块所产生的一切后果由使用者自行承担，作者不承担任何责任。请遵守当地法律法规，不要将本模块用于非法用途。

## 安装方法
1. 在 Magisk Manager 中刷入本模块 zip 文件
2. 重启设备
3. 模块将自动生效

## 卸载方法
在 Magisk Manager 中卸载本模块即可
