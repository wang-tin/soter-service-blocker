
#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="/data/local/tmp/soter_blocker_log.txt"

log_msg() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [Service] $1"
    echo "$msg" | tee -a "$LOGFILE" 2>/dev/null
}

log_msg "持续监控服务已启动 - SoterService 拦截模块 v1.8"

while true; do
    sleep 45
    
    log_msg "执行第 $(($COUNTER+1)) 轮安全拦截..."
    COUNTER=$((COUNTER+1))
    
    # 安全的系统属性设置
    setprop persist.sys.soter.enable false 2>/dev/null || true
    setprop ro.soter.service false 2>/dev/null || true
    setprop soter.service.enabled false 2>/dev/null || true
    setprop zygote.disable.soter true 2>/dev/null || true
    setprop debug.soter.disabled true 2>/dev/null || true
    
    # 安全的拦截标记
    mkdir -p /data/local/tmp/block_soter
    touch /data/local/tmp/block_soter/.soter_blocked 2>/dev/null || true
    
    log_msg "✓ 第 $COUNTER 轮拦截完成"
done
