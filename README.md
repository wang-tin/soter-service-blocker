
# SoterService拦截器

## 作者
王听

## 功能
强力拦截 SoterService，阻止任何应用（包括 com.chunqiunativecheck）调用它

## 特点
- 10 种强力拦截方法
- 完整日志记录
- 自动回滚机制
- 支持 Android 10-14
- 不使用 hook 和 Xposed 技术

## 10 种拦截方法
1. **pm disable**：直接禁用 SoterService 应用和组件
2. **权限限制**：chmod 000 阻止访问相关文件
3. **系统属性**：禁用 soter 和 zygote 相关系统属性
4. **SELinux 策略**：临时设置为宽容模式
5. **iptables 规则**：阻止网络连接和特定端口
6. **系统库替换**：替换 libsoter.so 为空文件
7. **Mount 隐藏**：用 mount bind 隐藏文件夹
8. **Zygote 拦截**：设置特殊属性和标记文件
9. **应用冻结**：冻结/卸载 com.chunqiunativecheck
10. **持久化**：确保重启后持续生效

## 拦截范围
- SoterService 文件夹
- SoterService.apk
- SoterService.vdex / .odex
- libsoter.so 系统库
- com.chunqiunativecheck 应用
- Soter 相关网络连接（端口 843）

## 兼容版本
- Android 10 (Q)
- Android 11 (R)
- Android 12 (S)
- Android 13 (T)
- Android 14 (U)

## 日志文件
- 主日志：`/data/local/tmp/soter_blocker_log.txt`
- 错误日志：`/data/local/tmp/soter_blocker_error.txt`
- 状态备份：`/data/local/tmp/soter_backup_state`

## 常见问题

### Q1: 如何验证模块是否生效？
```bash
# 查看日志
cat /data/local/tmp/soter_blocker_log.txt

# 检查 SoterService 状态
dumpsys activity services soter

# 检查 iptables 规则
iptables -L OUTPUT -n
```

### Q2: 卸载后如何恢复？
模块卸载脚本会自动恢复：
- 系统库（从 .bak 备份恢复）
- 文件权限（改为 644）
- iptables 规则（清除）
- 临时文件（清理）

### Q3: 拦截会影响其他应用吗？
- 主要影响 SoterService 和 com.chunqiunativecheck
- 可能影响依赖 Soter 的其他腾讯系应用（如微信支付）
- 网络规则可能影响部分功能

### Q4: 模块不工作怎么办？
1. 检查日志文件
2. 确保 Magisk 已获取 root 权限
3. 尝试手动执行：
   ```bash
   sh /data/local/tmp/soter_disable.sh
   ```

### Q5: 如何临时禁用拦截？
删除模块后重启即可自动恢复系统状态。

## 免责声明
本模块仅供学习和研究使用。使用本模块所产生的一切后果由使用者自行承担，作者不承担任何责任。请遵守当地法律法规，不要将本模块用于非法用途。

## 安装方法
1. 在 Magisk Manager 中刷入本模块 zip 文件
2. 重启设备
3. 查看日志确认生效：`cat /data/local/tmp/soter_blocker_log.txt`

## 卸载方法
1. 在 Magisk Manager 中禁用本模块
2. 重启设备
3. 再次在 Magisk Manager 中完全卸载
4. 模块会自动恢复系统状态

## 更新日志

### v1.6
- 添加完整日志系统
- 添加回滚机制
- 添加 SELinux 策略修改
- 添加 iptables 规则
- 添加系统库替换
- 添加应用冻结功能
- 完善错误处理

### v1.5
- 添加 Zygote 相关拦截

### v1.4
- 强力多重拦截方案

### v1.3
- 专门针对 com.chunqiunativecheck

### v1.0
- 初始版本
