
#!/system/bin/sh

MODDIR=${0%/*}

log -t SoterBlocker "服务已启动 - 持续强力拦截 SoterService"

# 持续监控和强制拦截
while true; do
    sleep 45
    
    # 持续禁用 SoterService 应用/组件
    if command -v pm &gt;/dev/null 2&gt;&amp;1; then
        pm disable-user --user 0 com.tencent.soter 2&gt;/dev/null || true
        pm disable-user --user 0 com.tencent.soter.service 2&gt;/dev/null || true
        pm disable-user --user 0 com.soter.service 2&gt;/dev/null || true
        pm disable --user 0 com.tencent.soter/.service.SoterService 2&gt;/dev/null || true
        pm disable --user 0 com.tencent.soter/.SoterService 2&gt;/dev/null || true
    fi
    
    # 持续权限限制
    chmod 000 /system_ext/app/SoterService 2&gt;/dev/null || true
    chmod 000 /system_ext/app/SoterService/SoterService.apk 2&gt;/dev/null || true
    chmod 000 /system_ext/app/SoterService/oat/arm64/SoterService.vdex 2&gt;/dev/null || true
    chmod 000 /system_ext/app/SoterService/oat/arm64/SoterService.odex 2&gt;/dev/null || true
    chmod 000 /system/app/SoterService 2&gt;/dev/null || true
    chmod 000 /system/app/SoterService/SoterService.apk 2&gt;/dev/null || true
    chmod 000 /system/app/SoterService/oat/arm64/SoterService.vdex 2&gt;/dev/null || true
    chmod 000 /system/app/SoterService/oat/arm64/SoterService.odex 2&gt;/dev/null || true
    
    # 持续禁用系统属性
    setprop persist.sys.soter.enable false
    setprop ro.soter.service false
    setprop soter.service.enabled false
    
    # 持续 mount 隐藏
    if [ -d "/system_ext/app/SoterService" ]; then
        mkdir -p /data/local/tmp/soter_empty
        mount --bind /data/local/tmp/soter_empty /system_ext/app/SoterService 2&gt;/dev/null || true
    fi
done
