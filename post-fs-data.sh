
#!/system/bin/sh

MODDIR=${0%/*}

sleep 30

# 检查 /system_ext/app/SoterService 文件夹
if [ -d "/system_ext/app/SoterService" ]; then
    log -t SoterBlocker "检测到 SoterService 文件夹"
fi

# 阻止 com.chunqiunativecheck 调用 SoterService
# 方法1: 通过权限限制
chmod 000 /system_ext/app/SoterService 2>/dev/null || true
chmod 000 /system/app/SoterService 2>/dev/null || true

# 方法2: 禁用相关系统属性
setprop persist.sys.soter.enable false
setprop ro.soter.service false

log -t SoterBlocker "SoterService 拦截已启动"
