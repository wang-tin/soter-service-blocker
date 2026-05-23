
#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="/data/local/tmp/soter_blocker_log.txt"
ERROR_LOG="/data/local/tmp/soter_blocker_error.txt"

mkdir -p /data/local/tmp

log_msg() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOGFILE" 2>/dev/null
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg" | tee -a "$ERROR_LOG" 2>/dev/null
}

log_msg "=========================================="
log_msg "SoterService 拦截模块 v1.8 开始启动"
log_msg "=========================================="

sleep 20

log_msg "启动完成 - 仅使用安全的拦截方法"

# 仅使用安全的系统属性设置
log_msg "[安全方法1] 设置系统属性..."
setprop persist.sys.soter.enable false 2>/dev/null && log_msg "✓ 已设置 persist.sys.soter.enable=false"
setprop ro.soter.service false 2>/dev/null && log_msg "✓ 已设置 ro.soter.service=false"
setprop soter.service.enabled false 2>/dev/null && log_msg "✓ 已设置 soter.service.enabled=false"
setprop zygote.disable.soter true 2>/dev/null && log_msg "✓ 已设置 zygote.disable.soter=true"
setprop debug.soter.disabled true 2>/dev/null && log_msg "✓ 已设置 debug.soter.disabled=true"

log_msg "[安全方法2] 创建拦截标记..."
mkdir -p /data/local/tmp/block_soter
touch /data/local/tmp/block_soter/.soter_blocked 2>/dev/null && log_msg "✓ 已创建拦截标记文件"

log_msg "=========================================="
log_msg "SoterService 拦截模块 v1.8 启动完成"
log_msg "=========================================="
