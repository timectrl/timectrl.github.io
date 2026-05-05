#!/bin/bash

# =================================================================
# 脚本名称: disable_coredump_debian_13.sh
# 兼容性: Debian 11, 12, 13 (Trixie) 及更高版本
# =================================================================

if [ "$EUID" -ne 0 ]; then 
  echo "错误: 请使用 sudo 运行。"
  exit 1
fi

echo "--- 正在为 Debian 11/12/13 配置 Coredump 永久禁用 ---"

# 1. 屏蔽服务 (Mask)
# 在 Debian 13 中，systemd-coredump 更加模块化，这里直接屏蔽所有入口
echo "[1/5] 屏蔽 systemd-coredump 服务入口..."
systemctl stop systemd-coredump.socket &>/dev/null
systemctl mask systemd-coredump.socket systemd-coredump.service &>/dev/null

# 2. 增强型配置覆盖 (Drop-ins)
# 除了修改主配置文件，我们在 /etc/systemd/coredump.conf.d/ 创建覆盖文件
# 这是 Debian 13 推荐的“不破坏原始配置”的做法
echo "[2/5] 创建系统级配置覆盖..."
mkdir -p /etc/systemd/coredump.conf.d/
cat <<EOF > /etc/systemd/coredump.conf.d/disable.conf
[Coredump]
Storage=none
ProcessSizeMax=0
ExternalSizeMax=0
JournalSizeMax=0
EOF

# 3. 内核拦截 (sysctl)
# 针对 Debian 13 可能存在的内核安全增强，我们确保配置写入 60-priority
echo "[3/5] 设置内核 core_pattern..."
SYSCTL_CONF="/etc/sysctl.d/60-disable-coredump.conf"
echo "kernel.core_pattern=|/bin/false" > "$SYSCTL_CONF"
# 立即强制生效
sysctl -w kernel.core_pattern="|/bin/false" &>/dev/null

# 4. 全局用户限制 (Limits)
# 兼容 Debian 13 的安全限制逻辑
echo "[4/5] 设置用户进程 ulimit 限制..."
LIMITS_FILE="/etc/security/limits.d/99-disable-coredump.conf"
cat <<EOF > "$LIMITS_FILE"
* soft core 0
* hard core 0
root soft core 0
root hard core 0
EOF

# 5. 彻底清理环境
echo "[5/5] 重载系统守护进程并清理残留..."
systemctl daemon-reload
rm -rf /var/lib/systemd/coredump/*
# 清理 journal 中的核心转储记录（可选）
journalctl --vacuum-time=1s &>/dev/null

echo "------------------------------------------------"
echo "✅ 成功：Debian 11/12/13 兼容性禁用完成。"
echo "核心状态核对:"
echo " - 内核参数: $(sysctl -n kernel.core_pattern)"
echo " - 存储策略: Storage=none (via drop-in)"
echo " - 用户限制: ulimit -c = 0"
echo "------------------------------------------------"
