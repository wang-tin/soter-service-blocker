
#!/system/bin/sh

MODDIR=${0%/*}

sleep 30

log -t SoterBlocker "开始拦截 com.chunqiunativecheck 对 SoterService 的调用"

# 检查 /system_ext/app/SoterService 文件夹
if [ -d "/system_ext/app/SoterService" ]; then
    log -t SoterBlocker "检测到 SoterService 文件夹"
fi

# 检查并拦截 SoterService.apk
if [ -f "/system_ext/app/SoterService/SoterService.apk" ]; then
    log -t SoterBlocker "检测到 SoterService.apk"
fi

# 检查并拦截 SoterService.vdex
if [ -f "/system_ext/app/SoterService/oat/arm64/SoterService.vdex" ]; then
    log -t SoterBlocker "检测到 SoterService.vdex"
fi

# 强制拦截方法1: 权限限制 - 文件夹和相关文件
chmod 000 /system_ext/app/SoterService 2>/dev/null || true
chmod 000 /system_ext/app/SoterService/SoterService.apk 2>/dev/null || true
chmod 000 /system_ext/app/SoterService/oat/arm64/SoterService.vdex 2>/dev/null || true
chmod 000 /system/app/SoterService 2>/dev/null || true
chmod 000 /system/app/SoterService/SoterService.apk 2>/dev/null || true
chmod 000 /system/app/SoterService/oat/arm64/SoterService.vdex 2>/dev/null || true

# 强制拦截方法2: 禁用相关系统属性
setprop persist.sys.soter.enable false
setprop ro.soter.service false

# 强制拦截方法3: 针对 com.chunqiunativecheck 包名的特殊处理
# 限制该应用的权限
if command -v appops &gt;/dev/null 2&gt;&amp;1; then
    appops set com.chunqiunativecheck GET_USAGE_STATS ignore 2&gt;/dev/null || true
    appops set com.chunqiunativecheck RUN_IN_BACKGROUND ignore 2&gt;/dev/null || true
    log -t SoterBlocker "已通过 appops 限制 com.chunqiunativecheck"
fi

log -t SoterBlocker "SoterService 拦截已完成 - 专门针对 com.chunqiunativecheck"
