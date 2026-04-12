#!/bin/bash

# =================================================================
# 脚本名称: fedora_nvidia_install.sh
# 适用系统: Fedora 38/39/40+
# 功能: 启用 RPM Fusion, 安装驱动, 处理 Secure Boot
# =================================================================

set -e

# 1. 权限检查
if [ "$EUID" -ne 0 ]; then
  echo "错误: 请使用 sudo 运行此脚本。"
  exit 1
fi

echo "--- [1/6] 正在启用 RPM Fusion 仓库 ---"
# 自动检测并安装 RPM Fusion，如果已存在则跳过
if ! rpm -q rpmfusion-free-release > /dev/null 2>&1; then
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                   https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
else
    echo "RPM Fusion 仓库已启用。"
fi

echo "--- [2/6] 更新系统软件包 ---"
dnf upgrade -y

echo "--- [3/6] 安装驱动与必要构建工具 ---"
# akmod-nvidia 会自动处理内核模块编译，并在内核更新时自动更新驱动
dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda kernel-devel

echo "--- [4/6] Secure Boot 安全启动处理 ---"
if [[ -d /sys/firmware/efi ]]; then
    SB_STATUS=$(mokutil --sb-state 2>/dev/null || echo "disabled")
    if [[ $SB_STATUS == *"enabled"* ]]; then
        echo "********************************************************"
        echo "检测到 Secure Boot 已开启。"
        echo "Fedora 需要安装并注册签名密钥 (kmodtool)。"
        echo "********************************************************"
        
        # 安装签名工具
        dnf install -y kmodtool akmods
        
        # 如果密钥不存在则创建
        if [ ! -f /etc/pki/akmods/certs/public_key.der ]; then
            /usr/sbin/kmodgenseig -a
        fi
        
        echo ">>> 请输入 MOK 临时密码进行密钥导入："
        mokutil --import /etc/pki/akmods/certs/public_key.der
        
        echo "-------------------------------------------------------"
        echo "重要提示：重启后在蓝色界面选择 'Enroll MOK'，然后输入刚才的密码。"
        echo "-------------------------------------------------------"
    fi
fi

echo "--- [5/6] 等待驱动模块后台编译 ---"
echo "正在触发 akmods 编译（请耐心等待，可能需要 1-3 分钟）..."
akmods --force

echo "--- [6/6] 刷新 Initramfs ---"
dracut -f

echo ""
echo "========================================================"
echo "脚本执行完毕！"
echo "请执行 'sudo reboot' 重启系统。"
if [[ $SB_STATUS == *"enabled"* ]]; then
    echo "重启关键点：Enroll MOK -> Continue -> Yes -> 密码 -> Reboot"
fi
echo "========================================================"

