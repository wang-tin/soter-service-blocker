
#!/system/bin/sh

MODDIR=${0%/*}

# 持续监控和拦截
while true; do
    sleep 60
    
    # 持续阻止 SoterService 访问
    if [ -d "/system_ext/app/SoterService" ]; then
        chmod 000 /system_ext/app/SoterService 2>/dev/null || true
    fi
    
    if [ -d "/system/app/SoterService" ]; then
        chmod 000 /system/app/SoterService 2>/dev/null || true
    fi
    
    # 阻止特定包名访问限制
    # 禁止 com.chunqiunativecheck
done
