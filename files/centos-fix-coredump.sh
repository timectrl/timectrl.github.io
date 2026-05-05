#!/bin/bash

# =================================================================
# 脚本名称: disable_coredump_centos10.sh
# 适用系统: CentOS Stream 10, RHEL 10, Rocky/AlmaLinux 10
# =================================================================

if [ "$EUID" -ne 0 ]; then 
  echo "请以 root 权限运行。"
  exit 1
fi

echo "--- 开始禁用 CentOS 10 Coredump (Systemd + ABRT) ---"

# 1. 禁用并屏蔽 systemd-coredump 服务
echo "[1/5] 屏蔽 systemd-coredump..."
systemctl stop systemd-coredump.socket &>/dev/null
systemctl mask systemd-coredump.socket systemd-coredump.service &>/dev/null

# 2. 禁用 ABRT (Red Hat 系特有的崩溃报告工具)
# ABRT 在 CentOS 中经常是 coredump 的实际接收者
echo "[2/5] 停止并禁用 ABRT 相关服务..."
systemctl stop abrtd.service abrt-oops.service abrt-xorg.service &>/dev/null
systemctl disable abrtd.service abrt-oops.service abrt-xorg.service &>/dev/null
systemctl mask abrtd.service &>/dev/null

# 3. 修改配置文件 (使用 Drop-in 模式)
echo "[3/5] 配置 coredump 存储策略为 none..."
mkdir -p /etc/systemd/coredump.conf.d/
cat <<EOF > /etc/systemd/coredump.conf.d/disable.conf
[Coredump]
Storage=none
ProcessSizeMax=0
EOF

# 4. 内核参数拦截 (最核心步骤)
# CentOS 10 默认可能会有 /usr/lib/sysctl.d/50-coredump.conf
# 我们通过在 /etc/sysctl.d/ 创建同名或更高优先级的后缀来覆盖它
echo "[4/5] 覆盖内核 core_pattern..."
SYSCTL_FILE="/etc/sysctl.d/99-disable-coredump.conf"
echo "kernel.core_pattern=|/bin/false" > "$SYSCTL_FILE"
sysctl -p "$SYSCTL_FILE" &>/dev/null

# 5. 设置全局资源限制
echo "[5/5] 设置 ulimit 资源限制..."
LIMITS_FILE="/etc/security/limits.d/99-disable-coredump.conf"
cat <<EOF > "$LIMITS_FILE"
* soft core 0
* hard core 0
root soft core 0
root hard core 0
EOF

# 清理并重载
rm -rf /var/lib/systemd/coredump/*
systemctl daemon-reload

echo "------------------------------------------------"
echo "✅ CentOS 10 Coredump 禁用完成！"
echo "当前内核 Pattern: $(sysctl -n kernel.core_pattern)"
echo "------------------------------------------------"
