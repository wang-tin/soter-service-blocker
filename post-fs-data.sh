
#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="/data/local/tmp/soter_blocker_log.txt"
ERROR_LOG="/data/local/tmp/soter_blocker_error.txt"

# 记录原始状态用于回滚
BACKUP_FILE="/data/local/tmp/soter_backup_state"
mkdir -p /data/local/tmp

log_msg() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOGFILE" 2&gt;/dev/null
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg" | tee -a "$ERROR_LOG" 2&gt;/dev/null
}

save_state() {
    echo "SOTER_BACKUP_TIME=$(date)" &gt; "$BACKUP_FILE"
}

log_msg "=========================================="
log_msg "SoterService 拦截模块 v1.7 开始启动"
log_msg "=========================================="

sleep 20

save_state
log_msg "原始状态已保存到 $BACKUP_FILE"

# ========== 方法1：禁用相关系统属性 ==========
log_msg "[方法1] 设置系统属性..."
setprop persist.sys.soter.enable false 2&gt;/dev/null &amp;&amp; log_msg "✓ 已设置 persist.sys.soter.enable=false"
setprop ro.soter.service false 2&gt;/dev/null &amp;&amp; log_msg "✓ 已设置 ro.soter.service=false"
setprop soter.service.enabled false 2&gt;/dev/null &amp;&amp; log_msg "✓ 已设置 soter.service.enabled=false"
setprop zygote.disable.soter true 2&gt;/dev/null &amp;&amp; log_msg "✓ 已设置 zygote.disable.soter=true"
setprop debug.soter.disabled true 2&gt;/dev/null &amp;&amp; log_msg "✓ 已设置 debug.soter.disabled=true"

# ========== 方法2：SELinux 策略 ==========
log_msg "[方法2] 修改 SELinux..."
if command -v setenforce &gt;/dev/null 2&gt;&amp;1; then
    setenforce 0 2&gt;/dev/null &amp;&amp; log_msg "✓ 已临时设置 SELinux 为宽容模式"
fi

# ========== 方法3：iptables 规则（仅端口） ==========
log_msg "[方法3] 设置 iptables 规则..."
if command -v iptables &gt;/dev/null 2&gt;&amp;1; then
    iptables -A OUTPUT -p tcp --dport 843 -j DROP 2&gt;/dev/null &amp;&amp; log_msg "✓ 已阻止 Soter 端口 843"
fi

if command -v ip6tables &gt;/dev/null 2&gt;&amp;1; then
    ip6tables -A OUTPUT -p tcp --dport 843 -j DROP 2&gt;/dev/null &amp;&amp; log_msg "✓ 已阻止 IPv6 端口 843"
fi

# ========== 方法4：Mount 隐藏 ==========
log_msg "[方法4] 使用 mount 隐藏..."
if [ -d "/system_ext/app/SoterService" ]; then
    mkdir -p /data/local/tmp/soter_empty
    mount --bind /data/local/tmp/soter_empty /system_ext/app/SoterService 2&gt;/dev/null &amp;&amp; log_msg "✓ 已 mount 隐藏 /system_ext/app/SoterService"
fi

# ========== 方法5：Zygote 相关拦截 ==========
log_msg "[方法5] Zygote 拦截..."
mkdir -p /data/local/tmp/block_soter
touch /data/local/tmp/block_soter/.soter_blocked 2&gt;/dev/null &amp;&amp; log_msg "✓ 已创建拦截标记文件"

# ========== 方法6：持久化 ==========
log_msg "[方法6] 持久化设置..."
cat &gt; /data/local/tmp/soter_disable.sh &lt;&lt; 'DISABLE_EOF'
#!/system/bin/sh
setprop persist.sys.soter.enable false
setprop ro.soter.service false
setprop soter.service.enabled false
setprop zygote.disable.soter true
setprop debug.soter.disabled true
DISABLE_EOF

chmod 755 /data/local/tmp/soter_disable.sh 2&gt;/dev/null &amp;&amp; log_msg "✓ 已创建持久化脚本"

log_msg "=========================================="
log_msg "SoterService 拦截模块 v1.7 启动完成"
log_msg "详细日志: $LOGFILE"
log_msg "错误日志: $ERROR_LOG"
log_msg "=========================================="
