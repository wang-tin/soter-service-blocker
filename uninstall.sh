
#!/system/bin/sh
MODDIR=${0%/*}
BACKUP_FILE="/data/local/tmp/soter_backup_state"
LOGFILE="/data/local/tmp/soter_blocker_log.txt"

echo "=========================================="
echo "SoterService 拦截模块卸载程序"
echo "=========================================="

# 恢复系统库
echo "[1/5] 恢复系统库..."
for lib in \
    "/system/lib64/libsoter.so.bak" \
    "/system/lib/libsoter.so.bak" \
    "/vendor/lib64/libsoter.so.bak" \
    "/vendor/lib/libsoter.so.bak"
do
    if [ -f "$lib" ]; then
        target="${lib%.bak}"
        cp -f "$lib" "$target"
        echo "✓ 已恢复 $target"
        rm -f "$lib"
    fi
done

# 恢复权限
echo "[2/5] 恢复文件权限..."
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
        chmod 644 "$target" 2>/dev/null && echo "✓ 已恢复 $target" || true
    fi
done

# 恢复系统属性
echo "[3/5] 恢复系统属性..."
if [ -f "$BACKUP_FILE" ]; then
    . "$BACKUP_FILE"
    echo "✓ 原始状态已从备份文件恢复"
else
    echo "未找到备份文件，跳过属性恢复"
fi

# 清除 iptables 规则
echo "[4/5] 清除 iptables 规则..."
if command -v iptables &>/dev/null 2>&1; then
    iptables -F OUTPUT 2>/dev/null && echo "✓ 已清除 iptables 规则" || true
fi

if command -v ip6tables &>/dev/null 2>&1; then
    ip6tables -F OUTPUT 2>/dev/null && echo "✓ 已清除 ip6tables 规则" || true
fi

# 清理临时文件
echo "[5/5] 清理临时文件..."
rm -rf /data/local/tmp/soter_empty 2>/dev/null || true
rm -rf /data/local/tmp/block_soter 2>/dev/null || true
rm -f /data/local/tmp/soter_disable.sh 2>/dev/null || true
rm -f "$BACKUP_FILE" 2>/dev/null || true
rm -f "$LOGFILE" 2>/dev/null || true
rm -f /data/local/tmp/soter_blocker_error.txt 2>/dev/null || true

echo "=========================================="
echo "卸载完成！"
echo "请重启设备以完成清理。"
echo "=========================================="

exit 0
