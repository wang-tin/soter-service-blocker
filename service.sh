
#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="/data/local/tmp/soter_blocker_log.txt"

log_msg() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [Service] $1"
    echo "$msg" | tee -a "$LOGFILE" 2&gt;/dev/null
}

log_msg "持续监控服务已启动 - SoterService 拦截模块 v1.7"
log_msg "日志文件: $LOGFILE"

while true; do
    sleep 45
    
    log_msg "执行第 $(($COUNTER+1)) 轮拦截检查..."
    COUNTER=$((COUNTER+1))
    
    # 持续设置系统属性
    setprop persist.sys.soter.enable false 2&gt;/dev/null || true
    setprop ro.soter.service false 2&gt;/dev/null || true
    setprop soter.service.enabled false 2&gt;/dev/null || true
    setprop zygote.disable.soter true 2&gt;/dev/null || true
    setprop debug.soter.disabled true 2&gt;/dev/null || true
    
    # 持续 SELinux
    if command -v setenforce &gt;/dev/null 2&gt;&amp;1; then
        setenforce 0 2&gt;/dev/null || true
    fi
    
    # 持续 iptables（仅端口）
    if command -v iptables &gt;/dev/null 2&gt;&amp;1; then
        iptables -A OUTPUT -p tcp --dport 843 -j DROP 2&gt;/dev/null || true
    fi
    
    if command -v ip6tables &gt;/dev/null 2&gt;&amp;1; then
        ip6tables -A OUTPUT -p tcp --dport 843 -j DROP 2&gt;/dev/null || true
    fi
    
    # 持续 mount 隐藏
    if [ -d "/system_ext/app/SoterService" ]; then
        mkdir -p /data/local/tmp/soter_empty
        mount --bind /data/local/tmp/soter_empty /system_ext/app/SoterService 2&gt;/dev/null || true
    fi
    
    # 持续 Zygote 标记
    mkdir -p /data/local/tmp/block_soter
    touch /data/local/tmp/block_soter/.soter_blocked 2&gt;/dev/null || true
    
    log_msg "✓ 第 $COUNTER 轮拦截完成"
    
    # 每 10 轮记录一次
    if [ $((COUNTER % 10)) -eq 0 ]; then
        log_msg "--- 第 $COUNTER 轮详细检查 ---"
        if command -v dumpsys &gt;/dev/null 2&gt;&amp;1; then
            dumpsys activity services soter 2&gt;/dev/null | head -n 5 &gt;&gt; "$LOGFILE" || true
        fi
        log_msg "--- 详细日志记录完成 ---"
    fi
done
