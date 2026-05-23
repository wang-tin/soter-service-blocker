
# SoterService拦截器

## 作者
王听

## 功能
强力拦截 SoterService，阻止任何应用（包括 com.chunqiunativecheck）调用它

## 特点
- **不冻结/删除应用**
- 6 种安全的拦截方法
- 完整日志记录
- 自动回滚机制
- 支持 Android 10-14
- 不使用 hook 和 Xposed 技术

## 6 种拦截方法
1. **系统属性**：禁用 soter 和 zygote 相关系统属性
2. **SELinux 策略**：临时设置为宽容模式
3. **iptables 规则**：阻止端口 843 网络连接
4. **Mount 隐藏**：用 mount bind 隐藏文件夹
5. **Zygote 拦截**：设置特殊属性和标记文件
6. **持久化**：确保重启后持续生效

## 拦截范围
- SoterService 文件夹
- Soter 相关系统属性
- 端口 843 网络连接
- 通过 Zygote 的加载尝试

## 兼容版本
- Android 10 (Q)
- Android 11 (R)
- Android 12 (S)
- Android 13 (T)
- Android 14 (U)

## 日志文件
- 主日志：`/data/local/tmp/soter_blocker_log.txt`
- 错误日志：`/data/local/tmp/soter_blocker_error.txt`

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
- iptables 规则（清除）
- 临时文件（清理）

### Q3: 会影响其他应用吗？
- 主要影响 SoterService 相关功能
- 不会冻结或删除任何应用

### Q4: 模块不工作怎么办？
1. 检查日志文件
2. 确保 Magisk 已获取 root 权限
3. 查看哪些方法成功/失败

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
4. 模块会自动清理临时文件

## 更新日志

### v1.7
- ✅ 移除 pm disable 应用和组件（系统只读失败）
- ✅ 移除权限限制（无法修改系统分区）
- ✅ 移除 iptables UID 规则（失败）
- ✅ 移除应用冻结和卸载功能
- ✅ 只保留工作良好的 6 种方法
- ✅ 优化代码，减少错误日志

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
