#!/bin/bash

# 字体颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
WHITE='\033[0;37m'
PLAIN='\033[0m'

# 检查并自动安装核心依赖（全静默重构版）
check_dependencies() {
    for cmd in curl wget; do
        if ! command -v $cmd &> /dev/null; then
            if [ -f /etc/debian_version ]; then
                apt-get update -y >/dev/null 2>&1 && apt-get install -y $cmd >/dev/null 2>&1
            elif [ -f /etc/redhat-release ]; then
                yum install -y $cmd >/dev/null 2>&1
            else
                echo -e "${RED}无法识别的系统，请手动安装 $cmd 后再运行本脚本！${PLAIN}"
                exit 1
            fi
        fi
    done
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
    echo -e "${YELLOW}12.${PLAIN} ${WHITE}硬件质量体检${PLAIN}"
    echo -e "${YELLOW}13.${PLAIN} ${WHITE}三网回程线路测试${PLAIN}"
    echo -e "${YELLOW}14.${PLAIN} ${WHITE}三网回程路由测试${PLAIN}"
    echo -e "${YELLOW}15.${PLAIN} ${WHITE}VPS测速${PLAIN}"
    echo -e ""
    echo -e "${YELLOW}--- 🛠️ 其它脚本 ---${PLAIN}"
    echo -e "${YELLOW}16.${PLAIN} ${WHITE}WARP 多功能一键脚本${PLAIN}"
    echo -e "${YELLOW}17.${PLAIN} ${WHITE}ACME 一键证书申请${PLAIN}"
    echo -e "${YELLOW}18.${PLAIN} ${RED}禁用ipv6${PLAIN}"
    echo -e "${YELLOW}19.${PLAIN} ${GREEN}启用Ipv6${PLAIN}"
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
    # 先重启全局网络服务
    if [ -f /etc/debian_version ]; then
        systemctl restart networking >/dev/null 2>&1
    elif [ -f /etc/redhat-release ]; then
        systemctl restart network >/dev/null 2>&1
    fi
    
    # 🌟 MAX多网卡自动遍历下发重构 🌟
    # 自动获取当前系统下所有除 lo 以外的活跃网络接口名，最大化并发请求获取
    interfaces=$(ls /sys/class/net | grep -v lo)
    for iface in $interfaces; do
        if [ -d "/sys/class/net/$iface" ]; then
            # 对所有物理/虚拟网卡并行发起带有不等待(N)和非阻塞(W)的IPv6获取指令
            dhclient -6 -NW "$iface" >/dev/null 2>&1 &
        fi
    done
    wait # 等待所有后台网络下发任务执行完毕
    
    echo -e "${GREEN}IPv6 协议及多网卡并发获取已成功恢复启用！${PLAIN}"
    echo -e "${YELLOW}提示：先使用ip a 查看 IPv6 是否获取成功，若 IPv6 一直获取不成功，则 (reboot) 重启下系统。${PLAIN}"
}

# 脚本运行入口，先执行静默依赖检查
check_dependencies

while true; do
    show_menu
    read -p "请输入选项符号 (0-19): " num
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
            bash <(curl -Ls https://Check.Place) -H
            ;;
        13)
            curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
            ;;
        14)
            bash <(curl -Ls https://raw.githubusercontent.com/nxtrace/Nxtrace-core/main/get_nxtrace.sh)
            ;;
        15)
            wget https://github.com/flben233/cdn-speed/releases/download/v20260503-062319/cdn-speed-linux-amd64 && chmod +x ./cdn-speed-linux-amd64 && { ./cdn-speed-linux-amd64; rm -f ./cdn-speed-linux-amd64 cdn-speed.log ; }
            ;;
        16)
            wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
            ;;
        17)
            bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/acme-yg/main/acme.sh)
            ;;
        18)
            disable_ipv6
            ;;
        19)
            enable_ipv6
            ;;
        0)
            echo -e "${WHITE}诶？！要退出吗(•́ ✖ •̀)是我不对！请不要把我当成赛博垃圾丢掉啊拜拜……${PLAIN}"
            exit 0
            ;;
        *)
            echo -e "${RED}输入错误，请输入 0 到 19 之间的数字！${PLAIN}"
            ;;
    esac
    echo ""
    read -p "按回车键返回主菜单..." env
done