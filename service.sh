
#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="/data/local/tmp/soter_blocker_log.txt"
ERROR_LOG="/data/local/tmp/soter_blocker_error.txt"

log_msg() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [Service] $1"
    echo "$msg" | tee -a "$LOGFILE" 2>/dev/null
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [Service] ERROR: $1"
    echo "$msg" | tee -a "$ERROR_LOG" 2>/dev/null
}

log_msg "持续监控服务已启动 - SoterService 拦截模块 v1.6"
log_msg "日志文件: $LOGFILE"

# 持续监控和强制拦截
while true; do
    sleep 45
    
    log_msg "执行第 $(($COUNTER+1)) 轮拦截检查..."
    COUNTER=$((COUNTER+1))
    
    # ========== 持续禁用 SoterService 应用/组件 ==========
    if command -v pm &>/dev/null 2>&1; then
        pm disable-user --user 0 com.tencent.soter 2>/dev/null || true
        pm disable-user --user 0 com.tencent.soter.service 2>/dev/null || true
        pm disable-user --user 0 com.soter.service 2>/dev/null || true
        pm disable --user 0 com.tencent.soter/.service.SoterService 2>/dev/null || true
        pm disable --user 0 com.tencent.soter/.SoterService 2>/dev/null || true
        
        # 持续冻结/卸载 com.chunqiunativecheck
        pm freeze com.chunqiunativecheck 2>/dev/null || true
        pm uninstall -k com.chunqiunativecheck 2>/dev/null || true
        
        log_msg "✓ 已刷新禁用状态"
    fi
    
    # ========== 持续权限限制 ==========
    for target in \
        "/system_ext/app/SoterService" \
        "/system_ext/app/SoterService/SoterService.apk" \
        "/system_ext/app/SoterService/oat/arm64/SoterService.vdex" \
        "/system_ext/app/SoterService/oat/arm64/SoterService.odex" \
        "/system/app/SoterService" \
        "/system/app/SoterService/SoterService.apk" \
        "/system/app/SoterService/oat/arm64/SoterService.vdex" \
        "/system/app/SoterService/oat/arm64/SoterService.odex"
    do
        if [ -e "$target" ] || [ -d "$target" ]; then
            chmod 000 "$target" 2>/dev/null || true
        fi
    done
    
    # ========== 持续禁用系统属性 ==========
    setprop persist.sys.soter.enable false 2>/dev/null || true
    setprop ro.soter.service false 2>/dev/null || true
    setprop soter.service.enabled false 2>/dev/null || true
    setprop zygote.disable.soter true 2>/dev/null || true
    setprop debug.soter.disabled true 2>/dev/null || true
    
    # ========== 持续 SELinux 策略 ==========
    if command -v setenforce &>/dev/null 2>&1; then
        setenforce 0 2>/dev/null || true
    fi
    
    # ========== 持续 iptables 规则 ==========
    if command -v iptables &>/dev/null 2>&1; then
        # 清除旧规则并重新设置
        iptables -F OUTPUT 2>/dev/null || true
        iptables -A OUTPUT -m owner --uid-owner $(id -u com.tencent.soter 2>/dev/null) -j DROP 2>/dev/null || true
        iptables -A OUTPUT -p tcp --dport 843 -j DROP 2>/dev/null || true
    fi
    
    if command -v ip6tables &>/dev/null 2>&1; then
        ip6tables -F OUTPUT 2>/dev/null || true
        ip6tables -A OUTPUT -m owner --uid-owner $(id -u com.tencent.soter 2>/dev/null) -j DROP 2>/dev/null || true
    fi
    
    # ========== 持续系统库替换 ==========
    for lib in \
        "/system/lib64/libsoter.so" \
        "/system/lib/libsoter.so" \
        "/vendor/lib64/libsoter.so" \
        "/vendor/lib/libsoter.so"
    do
        if [ -f "${lib}.bak" ]; then
            > "$lib" 2>/dev/null || true
        fi
    done
    
    # ========== 持续 mount 隐藏 ==========
    if [ -d "/system_ext/app/SoterService" ]; then
        mkdir -p /data/local/tmp/soter_empty
        mount --bind /data/local/tmp/soter_empty /system_ext/app/SoterService 2>/dev/null || true
    fi
    
    # ========== 持续 Zygote 相关拦截 ==========
    mkdir -p /data/local/tmp/block_soter
    touch /data/local/tmp/block_soter/.soter_blocked 2>/dev/null || true
    
    # ========== 记录日志 ==========
    log_msg "✓ 第 $COUNTER 轮拦截完成"
    
    # 每10轮记录一次详细日志
    if [ $((COUNTER % 10)) -eq 0 ]; then
        log_msg "--- 第 $COUNTER 轮详细检查 ---"
        
        # 检查 SoterService 状态
        if command -v dumpsys &>/dev/null 2>&1; then
            dumpsys activity services soter 2>/dev/null | head -n 5 >> "$LOGFILE" || true
        fi
        
        # 检查 com.chunqiunativecheck 状态
        if command -v pm &>/dev/null 2>&1; then
            pm list packages | grep -i soter >> "$LOGFILE" 2>/dev/null || true
        fi
        
        log_msg "--- 详细日志记录完成 ---"
    fi
done
