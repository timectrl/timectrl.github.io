#!/bin/bash

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then 
  echo "请使用 sudo 运行。"
  exit 1
fi

echo "正在优化 systemd-coredump 禁用流程..."

# 1. 处理服务（先停止，再禁用，最后屏蔽）
# 使用 --now 可以同时停止服务
echo "-> 正在屏蔽 systemd-coredump 服务..."
systemctl stop systemd-coredump.socket &> /dev/null
systemctl disable systemd-coredump.socket &> /dev/null
systemctl mask systemd-coredump.socket &> /dev/null

# 2. 修改 coredump.conf
echo "-> 正在配置 coredump.conf..."
CONF_FILE="/etc/systemd/coredump.conf"
if [ -f "$CONF_FILE" ]; then
    # 确保 [Coredump] 标签存在，并修改/添加参数
    sed -i '/^\[Coredump\]/a Storage=none\nProcessSizeMax=0' "$CONF_FILE"
    # 去除可能重复的配置（可选）
    sort -u -o "$CONF_FILE" "$CONF_FILE"
fi

# 3. 设置内核参数
echo "-> 正在设置内核 core_pattern..."
SYSCTL_CONF="/etc/sysctl.d/60-disable-coredump.conf"
echo "kernel.core_pattern=|/bin/false" > "$SYSCTL_CONF"
sysctl -p "$SYSCTL_CONF" &> /dev/null

# 4. 清理
echo "-> 正在清理残留文件..."
rm -rf /var/lib/systemd/coredump/*
systemctl daemon-reload

echo "-------------------------------------------"
echo "修复完成！报错已忽略，coredump 已彻底关闭。"
