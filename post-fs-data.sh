
#!/system/bin/sh

MODDIR=${0%/*}

sleep 20

log -t SoterBlocker "=== 开始强制拦截 SoterService ==="

# 强力拦截方法1: 直接禁用 SoterService 应用/组件
if command -v pm &gt;/dev/null 2&gt;&amp;1; then
    # 尝试禁用可能的 SoterService 包名
    pm disable-user --user 0 com.tencent.soter 2&gt;/dev/null || true
    pm disable-user --user 0 com.tencent.soter.service 2&gt;/dev/null || true
    pm disable-user --user 0 com.soter.service 2&gt;/dev/null || true
    
    # 禁用所有可能的 Soter 相关组件
    pm disable --user 0 com.tencent.soter/.service.SoterService 2&gt;/dev/null || true
    pm disable --user 0 com.tencent.soter/.SoterService 2&gt;/dev/null || true
    
    log -t SoterBlocker "已尝试禁用 SoterService 应用/组件"
fi

# 强力拦截方法2: 权限限制 - 文件夹和相关文件
chmod 000 /system_ext/app/SoterService 2&gt;/dev/null || true
chmod 000 /system_ext/app/SoterService/SoterService.apk 2&gt;/dev/null || true
chmod 000 /system_ext/app/SoterService/oat/arm64/SoterService.vdex 2&gt;/dev/null || true
chmod 000 /system_ext/app/SoterService/oat/arm64/SoterService.odex 2&gt;/dev/null || true
chmod 000 /system/app/SoterService 2&gt;/dev/null || true
chmod 000 /system/app/SoterService/SoterService.apk 2&gt;/dev/null || true
chmod 000 /system/app/SoterService/oat/arm64/SoterService.vdex 2&gt;/dev/null || true
chmod 000 /system/app/SoterService/oat/arm64/SoterService.odex 2&gt;/dev/null || true

# 强力拦截方法3: 禁用相关系统属性
setprop persist.sys.soter.enable false
setprop ro.soter.service false
setprop soter.service.enabled false
setprop zygote.disable.soter true
setprop debug.soter.disabled true

# 强力拦截方法4: 尝试用 mount 隐藏文件
if [ -d "/system_ext/app/SoterService" ]; then
    mkdir -p /data/local/tmp/soter_empty
    mount --bind /data/local/tmp/soter_empty /system_ext/app/SoterService 2&gt;/dev/null || true
    log -t SoterBlocker "已尝试 mount 隐藏 SoterService 文件夹"
fi

# 强力拦截方法5: Zygote 相关拦截 - 阻止进程加载
mkdir -p /data/local/tmp/block_soter
touch /data/local/tmp/block_soter/.soter_blocked

log -t SoterBlocker "=== SoterService 强制拦截完成（含 Zygote 拦截）==="
