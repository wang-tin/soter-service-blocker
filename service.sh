
#!/system/bin/sh

MODDIR=${0%/*}

log -t SoterBlocker "服务已启动 - 持续监控 com.chunqiunativecheck"

# 持续监控和强制拦截
while true; do
    sleep 60
    
    # 持续阻止 SoterService 访问 - 文件夹和相关文件
    if [ -d "/system_ext/app/SoterService" ]; then
        chmod 000 /system_ext/app/SoterService 2&gt;/dev/null || true
    fi
    
    if [ -f "/system_ext/app/SoterService/SoterService.apk" ]; then
        chmod 000 /system_ext/app/SoterService/SoterService.apk 2&gt;/dev/null || true
    fi
    
    if [ -f "/system_ext/app/SoterService/oat/arm64/SoterService.vdex" ]; then
        chmod 000 /system_ext/app/SoterService/oat/arm64/SoterService.vdex 2&gt;/dev/null || true
    fi
    
    if [ -d "/system/app/SoterService" ]; then
        chmod 000 /system/app/SoterService 2&gt;/dev/null || true
    fi
    
    if [ -f "/system/app/SoterService/SoterService.apk" ]; then
        chmod 000 /system/app/SoterService/SoterService.apk 2&gt;/dev/null || true
    fi
    
    if [ -f "/system/app/SoterService/oat/arm64/SoterService.vdex" ]; then
        chmod 000 /system/app/SoterService/oat/arm64/SoterService.vdex 2&gt;/dev/null || true
    fi
    
    # 针对 com.chunqiunativecheck 包名的持续强制拦截
    if command -v appops &gt;/dev/null 2&gt;&amp;1; then
        appops set com.chunqiunativecheck GET_USAGE_STATS ignore 2&gt;/dev/null || true
        appops set com.chunqiunativecheck RUN_IN_BACKGROUND ignore 2&gt;/dev/null || true
    fi
    
    # 确保系统属性保持禁用状态
    setprop persist.sys.soter.enable false
    setprop ro.soter.service false
done
