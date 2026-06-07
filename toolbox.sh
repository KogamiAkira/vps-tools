#!/bin/bash

# 字体颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
WHITE='\033[0;37m'
PLAIN='\033[0m'

# 检查并自动安装核心依赖
check_dependencies() {
    clear
    echo -e "${YELLOW}正在检查系统核心依赖 (curl / wget)...${PLAIN}"
    
    for cmd in curl wget; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${YELLOW}未检测到 $cmd，正在自动为您安装...${PLAIN}"
            if [ -f /etc/debian_version ]; then
                apt-get update -y && apt-get install -y $cmd
            elif [ -f /etc/redhat-release ]; then
                yum install -y $cmd
            else
                echo -e "${RED}无法识别的系统，请手动安装 $cmd 后再运行本脚本！${PLAIN}"
                exit 1
            fi
        fi
    done
    echo -e "${GREEN}核心依赖就绪！正在进入主菜单...${PLAIN}"
    sleep 1.2
}

show_menu() {
    clear # 将清屏动作放在菜单打印的最开头，确保渲染完全同步
    echo -e "${GREEN}==================================================${PLAIN}"
    echo -e "${BLUE}           Kogami Akira的聚合脚本                 ${PLAIN}"
    echo -e "${BLUE}               by: Kogami Akira                    ${PLAIN}"
    echo -e "${GREEN}==================================================${PLAIN}"
    echo -e "${YELLOW}--- 🚀 BBR安装 ---${PLAIN}"
    echo -e " ${YELLOW}1.${PLAIN} ${WHITE}安装 BBRv3加速${PLAIN}"
    echo -e " ${YELLOW}2.${PLAIN} ${WHITE}安装 BBR / 锐速加速${PLAIN}"
    echo -e ""
    echo -e "${YELLOW}--- 🎨 面板安装 ---${PLAIN}"
    echo -e " ${YELLOW}3.${PLAIN} ${WHITE}安装 3x-ui 面版${PLAIN}"
    echo -e " ${YELLOW}4.${PLAIN} ${WHITE}安装 s-ui 面版${PLAIN}"
    echo -e " ${YELLOW}5.${PLAIN} ${WHITE}安装 x-ui 面版${PLAIN}"
    echo -e ""
    echo -e "${YELLOW}--- 🔗 懒人搭建脚本 ---${PLAIN}"
    echo -e " ${YELLOW}6.${PLAIN} ${WHITE}安装 老王 sing-box 四合一${PLAIN}"
    echo -e " ${YELLOW}7.${PLAIN} ${WHITE}安装 勇哥 sing-box 一键脚本${PLAIN}"
    echo -e ""
    echo -e "${YELLOW}--- 📈 综合测试 ---${PLAIN}"
    echo -e " ${YELLOW}8.${PLAIN} ${WHITE}聚合怪性能测试${PLAIN}"
    echo -e " ${YELLOW}9.${PLAIN} ${WHITE}流媒体解锁测试${PLAIN}"
    echo -e "${YELLOW}10.${PLAIN} ${WHITE}IP 质量检测${PLAIN}"
    echo -e "${YELLOW}11.${PLAIN} ${WHITE}网络质量体检${PLAIN}"
    echo -e "${YELLOW}12.${PLAIN} ${WHITE}三网回程线路测试${PLAIN}"
    echo -e "${YELLOW}13.${PLAIN} ${WHITE}三网回程路由测试${PLAIN}"
    echo -e "${YELLOW}14.${PLAIN} ${WHITE}VPS测速${PLAIN}"
    echo -e ""
    echo -e "${YELLOW}--- 🛠️ 其它脚本 ---${PLAIN}"
    echo -e "${YELLOW}15.${PLAIN} ${WHITE}WARP 多功能一键脚本${PLAIN}"
    echo -e "${YELLOW}16.${PLAIN} ${WHITE}ACME 一键证书申请${PLAIN}"
    echo -e "${YELLOW}17.${PLAIN} ${RED}禁用ipv6${PLAIN}"
    echo -e "${YELLOW}18.${PLAIN} ${GREEN}启用Ipv6${PLAIN}"
    echo -e " ${YELLOW}0.${PLAIN} ${WHITE}退出脚本${PLAIN}"
    echo -e "${GREEN}==================================================${PLAIN}"
}

disable_ipv6() {
    echo -e "${YELLOW}正在永久禁用 IPv6...${PLAIN}"
    sed -i '/net.ipv6.conf/d' /etc/sysctl.conf
    cat >> /etc/sysctl.conf << 'NOD6'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
NOD6
    sysctl -p >/dev/null 2>&1
    echo -e "${GREEN}IPv6 已成功永久禁用！已生效。${PLAIN}"
}

enable_ipv6() {
    echo -e "${YELLOW}正在永久启用 IPv6...${PLAIN}"
    sed -i '/net.ipv6.conf/d' /etc/sysctl.conf
    cat >> /etc/sysctl.conf << 'YES6'
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
YES6
    sysctl -p >/dev/null 2>&1
    
    echo -e "${YELLOW}正在尝试刷新网络接口获取 IPv6 地址...${PLAIN}"
    if [ -f /etc/debian_version ]; then
        systemctl restart networking >/dev/null 2>&1
        # 自动获取当前活动的物理网卡名称，避免写死 eth1 导致别的机器不兼容
        local active_interface=$(ip -4 route show to default | awk '{print $5}' | head -n 1)
        if [ -n "$active_interface" ]; then
            dhclient -6 -r "$active_interface" >/dev/null 2>&1 # 释放旧租约
            dhclient -6 -NW "$active_interface" >/dev/null 2>&1 # 后台自动获取，绝不卡死
        fi
    elif [ -f /etc/redhat-release ]; then
        systemctl restart network >/dev/null 2>&1
    fi
    
    echo -e "${GREEN}IPv6 协议已成功恢复启用！后台正在自动获取 IP，无需重启。${PLAIN}"
}

# 脚本运行入口，先执行依赖检查
check_dependencies

while true; do
    show_menu
    read -p "请输入选项符号 (0-18): " num
    case "$num" in
        1)
            bash <(curl -Ls https://raw.githubusercontent.com/byJoey/Actions-bbr-v3/refs/heads/main/install.sh)
            ;;
        2)
            wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
            ;;
        3)
            bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
            ;;
        4)
            bash <(curl -Ls https://raw.githubusercontent.com/admin8800/s-ui/main/install.sh)
            ;;
        5)
            bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
            ;;
        6)
            bash <(curl -Ls https://raw.githubusercontent.com/eooce/sing-box/main/sing-box.sh)
            ;;
        7)
            bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)
            ;;
        8)
            curl -L https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
            ;;
        9)
            bash <(curl -L -s check.unlock.media)
            ;;
        10)
            bash <(curl -Ls https://Check.Place) -I
            ;;
        11)
            bash <(curl -Ls https://Check.Place) -N
            ;;
        12)
            curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
            ;;
        13)
            bash <(curl -Ls https://raw.githubusercontent.com/nxtrace/Nxtrace-core/main/get_nxtrace.sh)
            ;;
        14)
            wget https://github.com/flben233/cdn-speed/releases/download/v20260503-062319/cdn-speed-linux-amd64 && chmod +x ./cdn-speed-linux-amd64 && { ./cdn-speed-linux-amd64; rm -f ./cdn-speed-linux-amd64 cdn-speed.log ; }
            ;;
        15)
            wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
            ;;
        16)
            bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/acme-yg/main/acme.sh)
            ;;
        17)
            disable_ipv6
            ;;
        18)
            enable_ipv6
            ;;
        0)
            echo -e "${BLUE}退出工具箱，祝您用机愉快！${PLAIN}"
            exit 0
            ;;
        *)
            echo -e "${RED}输入错误，请输入 0 到 18 之间的数字！${PLAIN}"
            ;;
    esac
    echo ""
    read -p "按回车键返回主菜单..." env
done
