#!/bin/bash

# =================================================================
# 脚本名称: nvidia_install_fixed.sh
# 功能: 自动配置源、安装驱动、处理 Secure Boot 签名
# 适用系统: Debian 12 (Bookworm) 及以上
# =================================================================

set -e # 遇到错误立即停止

# 1. 权限检查
if [ "$EUID" -ne 0 ]; then
  echo "错误: 请使用 sudo 运行此脚本。"
  exit 1
fi

echo "--- [1/6] 正在自动检测并配置软件源 (contrib/non-free) ---"
SOURCE_FILE="/etc/apt/sources.list"

# 检查是否已经包含必要的仓库组件
for component in contrib non-free non-free-firmware; do
    if ! grep -q "$component" "$SOURCE_FILE"; then
        echo "检测到缺少 $component，正在添加..."
        # 在包含 'main' 的行后面追加缺失的组件
        sed -i "/^deb.*main/ s/$/ $component/" "$SOURCE_FILE"
        # 去重处理，防止同一行重复添加
        sed -i "s/$component $component/$component/g" "$SOURCE_FILE"
    else
        echo "组件 $component 已存在，跳过。"
    fi
done

echo "--- [2/6] 更新系统软件包列表 ---"
apt update

echo "--- [3/6] 安装检测工具与内核头文件 ---"
apt install -y nvidia-detect linux-headers-$(uname -r) dkms mokutil

echo "--- [4/6] 自动识别并安装 NVIDIA 驱动 ---"
RECOMMENDED_DRIVER=$(nvidia-detect | grep "nvidia-driver" || echo "nvidia-driver")
echo "推荐驱动: $RECOMMENDED_DRIVER"
apt install -y $RECOMMENDED_DRIVER

echo "--- [5/6] Secure Boot 安全启动处理 ---"
SB_STATUS=$(mokutil --sb-state)
echo "当前 Secure Boot 状态: $SB_STATUS"

if [[ $SB_STATUS == *"enabled"* ]]; then
    echo "********************************************************"
    echo "注意: 检测到 Secure Boot 已开启。"
    echo "系统将提示你设置一个 MOK (Machine Owner Key) 临时密码。"
    echo "请记住此密码，并在重启后的蓝色界面中进行验证。"
    echo "********************************************************"
    read -p "按回车键开始配置签名..."
    dpkg-reconfigure nvidia-kernel-dkms
else
    echo "Secure Boot 未开启，跳过手动签名流程。"
fi

echo "--- [6/6] 禁用开源驱动 Nouveau ---"
if ! [ -f /etc/modprobe.d/blacklist-nouveau.conf ]; then
    echo -e "blacklist nouveau\noptions nouveau modeset=0" > /etc/modprobe.d/blacklist-nouveau.conf
    update-initramfs -u
    echo "Nouveau 已黑名单化。"
else
    echo "Nouveau 黑名单已存在。"
fi

echo ""
echo "========================================================"
echo "脚本执行完毕！"
if [[ $SB_STATUS == *"enabled"* ]]; then
    echo "请执行 'sudo reboot' 重启。"
    echo "重启时在蓝色界面选择: Enroll MOK -> Continue -> Yes -> 输入密码 -> Reboot"
else
    echo "请执行 'sudo reboot' 重启以启用驱动。"
fi
echo "========================================================"
