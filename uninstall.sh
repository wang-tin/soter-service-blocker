
#!/system/bin/sh

echo "=========================================="
echo "SoterService 拦截模块卸载程序"
echo "=========================================="

echo "[1/1] 清理临时文件..."
rm -rf /data/local/tmp/block_soter 2>/dev/null || true
rm -f /data/local/tmp/soter_blocker_log.txt 2>/dev/null || true
rm -f /data/local/tmp/soter_blocker_error.txt 2>/dev/null || true

echo "=========================================="
echo "卸载完成！"
echo "请重启设备。"
echo "=========================================="

exit 0
