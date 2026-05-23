
#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="/data/local/tmp/soter_blocker_log.txt"
ERROR_LOG="/data/local/tmp/soter_blocker_error.txt"

# 记录原始状态用于回滚
BACKUP_FILE="/data/local/tmp/soter_backup_state"
mkdir -p /data/local/tmp

log_msg() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOGFILE" 2>/dev/null
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg" | tee -a "$ERROR_LOG" 2>/dev/null
}

# 保存状态用于回滚
save_state() {
    echo "SOTER_BACKUP_TIME=$(date)" > "$BACKUP_FILE"
    getprop persist.sys.soter.enable >> "$BACKUP_FILE" 2>/dev/null || echo "persist.sys.soter.enable=unknown" >> "$BACKUP_FILE"
    getprop ro.soter.service >> "$BACKUP_FILE" 2>/dev/null || echo "ro.soter.service=unknown" >> "$BACKUP_FILE"
}

log_msg "=========================================="
log_msg "SoterService 拦截模块 v1.6 开始启动"
log_msg "=========================================="

# 等待系统初始化
sleep 20

save_state
log_msg "原始状态已保存到 $BACKUP_FILE"

# ========== 方法1: 强力拦截 SoterService 应用/组件 ==========
log_msg "[方法1] 尝试禁用 SoterService 应用和组件..."

if command -v pm &>/dev/null 2>&1; then
    # 尝试禁用可能的 SoterService 包名
    pm disable-user --user 0 com.tencent.soter 2>/dev/null && \
        log_msg "✓ 已禁用 com.tencent.soter" || log_error "禁用 com.tencent.soter 失败"
    
    pm disable-user --user 0 com.tencent.soter.service 2>/dev/null && \
        log_msg "✓ 已禁用 com.tencent.soter.service" || log_error "禁用 com.tencent.soter.service 失败"
    
    pm disable-user --user 0 com.soter.service 2>/dev/null && \
        log_msg "✓ 已禁用 com.soter.service" || log_error "禁用 com.soter.service 失败"
    
    # 禁用所有可能的 Soter 相关组件
    pm disable --user 0 com.tencent.soter/.service.SoterService 2>/dev/null && \
        log_msg "✓ 已禁用 SoterService 组件" || log_error "禁用 SoterService 组件失败"
    
    pm disable --user 0 com.tencent.soter/.SoterService 2>/dev/null && \
        log_msg "✓ 已禁用 SoterService 组件2" || log_error "禁用 SoterService 组件2 失败"
else
    log_error "pm 命令不可用"
fi

# ========== 方法2: 权限限制 - 文件夹和相关文件 ==========
log_msg "[方法2] 尝试设置权限限制..."

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
        chmod 000 "$target" 2>/dev/null && \
            log_msg "✓ 已限制 $target" || \
            log_error "限制 $target 失败"
    fi
done

# ========== 方法3: 系统属性 - 禁用相关属性 ==========
log_msg "[方法3] 尝试设置系统属性..."

setprop persist.sys.soter.enable false 2>/dev/null && \
    log_msg "✓ 已设置 persist.sys.soter.enable=false" || log_error "设置 persist.sys.soter.enable 失败"

setprop ro.soter.service false 2>/dev/null && \
    log_msg "✓ 已设置 ro.soter.service=false" || log_error "设置 ro.soter.service 失败"

setprop soter.service.enabled false 2>/dev/null && \
    log_msg "✓ 已设置 soter.service.enabled=false" || log_error "设置 soter.service.enabled 失败"

setprop zygote.disable.soter true 2>/dev/null && \
    log_msg "✓ 已设置 zygote.disable.soter=true" || log_error "设置 zygote.disable.soter 失败"

setprop debug.soter.disabled true 2>/dev/null && \
    log_msg "✓ 已设置 debug.soter.disabled=true" || log_error "设置 debug.soter.disabled 失败"

# ========== 方法4: SELinux 策略 ==========
log_msg "[方法4] 尝试修改 SELinux 策略..."

if command -v setenforce &>/dev/null 2>&1; then
    # 临时设置为宽容模式
    setenforce 0 2>/dev/null && log_msg "✓ 已临时设置 SELinux 为宽容模式" || log_error "设置 SELinux 失败"
fi

if command -v semanage &>/dev/null 2>&1; then
    # 禁用 soter 相关 SELinux 规则
    semanage boolean -m --off soter_service 2>/dev/null && \
        log_msg "✓ 已禁用 soter_service SELinux 布尔值" || \
        log_error "禁用 soter_service 失败"
fi

# 尝试使用 magiskpolicy 禁用规则
if [ -f "/data/adb/magisk/busybox" ]; then
    /data/adb/magisk/busybox sed -i 's/allow soter/deny soter/g' /data/system/ses掩步 2>/dev/null || true
fi

# ========== 方法5: iptables 规则 ==========
log_msg "[方法5] 尝试设置 iptables 规则..."

if command -v iptables &>/dev/null 2>&1; then
    # 阻止 Soter 相关的网络连接
    iptables -A OUTPUT -m owner --uid-owner $(id -u com.tencent.soter 2>/dev/null) -j DROP 2>/dev/null && \
        log_msg "✓ 已阻止 Soter UID 的出站流量" || log_error "设置 iptables 失败"
    
    # 阻止特定端口
    iptables -A OUTPUT -p tcp --dport 843 -j DROP 2>/dev/null && \
        log_msg "✓ 已阻止 Soter 端口 843" || log_error "阻止端口 843 失败"
fi

if command -v ip6tables &>/dev/null 2>&1; then
    ip6tables -A OUTPUT -m owner --uid-owner $(id -u com.tencent.soter 2>/dev/null) -j DROP 2>/dev/null && \
        log_msg "✓ 已阻止 Soter UID 的 IPv6 出站流量" || log_error "设置 ip6tables 失败"
fi

# ========== 方法6: 系统库替换 ==========
log_msg "[方法6] 尝试替换系统库..."

for lib in \
    "/system/lib64/libsoter.so" \
    "/system/lib/libsoter.so" \
    "/vendor/lib64/libsoter.so" \
    "/vendor/lib/libsoter.so"
do
    if [ -f "$lib" ]; then
        # 备份原文件
        cp -f "$lib" "${lib}.bak" 2>/dev/null || true
        # 替换为空文件
        > "$lib" 2>/dev/null && \
            log_msg "✓ 已替换 $lib" || \
            log_error "替换 $lib 失败"
    fi
done

# ========== 方法7: Mount 隐藏 ==========
log_msg "[方法7] 尝试使用 mount 隐藏..."

if [ -d "/system_ext/app/SoterService" ]; then
    mkdir -p /data/local/tmp/soter_empty
    mount --bind /data/local/tmp/soter_empty /system_ext/app/SoterService 2>/dev/null && \
        log_msg "✓ 已 mount 隐藏 /system_ext/app/SoterService" || \
        log_error "mount 隐藏失败"
fi

# ========== 方法8: Zygote 相关拦截 ==========
log_msg "[方法8] 尝试 Zygote 相关拦截..."

mkdir -p /data/local/tmp/block_soter
touch /data/local/tmp/block_soter/.soter_blocked 2>/dev/null && \
    log_msg "✓ 已创建拦截标记文件" || log_error "创建标记文件失败"

# ========== 方法9: 针对 com.chunqiunativecheck 的专项处理 ==========
log_msg "[方法9] 尝试冻结/卸载 com.chunqiunativecheck..."

if command -v pm &>/dev/null 2>&1; then
    # 冻结应用
    pm freeze com.chunqiunativecheck 2>/dev/null && \
        log_msg "✓ 已冻结 com.chunqiunativecheck" || \
        log_error "冻结 com.chunqiunativecheck 失败"
    
    # 卸载更新（降级到系统版本）
    pm uninstall -k com.chunqiunativecheck 2>/dev/null && \
        log_msg "✓ 已卸载 com.chunqiunativecheck 更新" || \
        log_error "卸载 com.chunqiunativecheck 更新失败"
fi

# ========== 方法10: 持久化到系统启动 ==========
log_msg "[方法10] 尝试持久化到系统启动..."

# 创建禁用脚本
cat > /data/local/tmp/soter_disable.sh << 'DISABLE_EOF'
#!/system/bin/sh
pm disable-user --user 0 com.tencent.soter 2>/dev/null || true
pm disable-user --user 0 com.tencent.soter.service 2>/dev/null || true
pm disable-user --user 0 com.soter.service 2>/dev/null || true
setprop persist.sys.soter.enable false 2>/dev/null || true
setprop zygote.disable.soter true 2>/dev/null || true
DISABLE_EOF

chmod 755 /data/local/tmp/soter_disable.sh 2>/dev/null && \
    log_msg "✓ 已创建持久化脚本" || log_error "创建持久化脚本失败"

log_msg "=========================================="
log_msg "SoterService 拦截模块 v1.6 启动完成"
log_msg "详细日志: $LOGFILE"
log_msg "错误日志: $ERROR_LOG"
log_msg "=========================================="
