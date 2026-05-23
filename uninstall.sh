
#!/system/bin/sh
MODDIR=${0%/*}
BACKUP_FILE="/data/local/tmp/soter_backup_state"
LOGFILE="/data/local/tmp/soter_blocker_log.txt"

echo "=========================================="
echo "SoterService 拦截模块卸载程序"
echo "=========================================="

# 清除 iptables 规则
echo "[1/2] 清除 iptables 规则..."
if command -v iptables &gt;/dev/null 2&gt;&amp;1; then
    iptables -F OUTPUT 2&gt;/dev/null &amp;&amp; echo "✓ 已清除 iptables 规则" || true
fi

if command -v ip6tables &gt;/dev/null 2&gt;&amp;1; then
    ip6tables -F OUTPUT 2&gt;/dev/null &amp;&amp; echo "✓ 已清除 ip6tables 规则" || true
fi

# 清理临时文件
echo "[2/2] 清理临时文件..."
rm -rf /data/local/tmp/soter_empty 2&gt;/dev/null || true
rm -rf /data/local/tmp/block_soter 2&gt;/dev/null || true
rm -f /data/local/tmp/soter_disable.sh 2&gt;/dev/null || true
rm -f "$BACKUP_FILE" 2&gt;/dev/null || true
rm -f "$LOGFILE" 2&gt;/dev/null || true
rm -f /data/local/tmp/soter_blocker_error.txt 2&gt;/dev/null || true

echo "=========================================="
echo "卸载完成！"
echo "请重启设备以完成清理。"
echo "=========================================="

exit 0
