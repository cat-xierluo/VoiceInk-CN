#!/bin/bash
# VoiceInk 本地化工具快捷启动脚本

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 切换到项目目录
cd "$PROJECT_DIR" || {
    echo "❌ 无法切换到项目目录: $PROJECT_DIR"
    exit 1
}

# 检查是否在正确的项目目录中
if [[ ! -d "VoiceInk" ]] || [[ ! -d "VoiceInk/en.lproj" ]]; then
    echo "❌ 当前目录不是VoiceInk项目根目录"
    echo "当前目录: $(pwd)"
    exit 1
fi

# 检查Python是否可用
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    exit 1
fi

# 检查本地化工具是否存在
if [[ ! -f "localization-tools/localize.py" ]]; then
    echo "❌ 本地化工具不存在，请先运行安装"
    echo "运行: python3 localization-tools/setup.py"
    exit 1
fi

# 显示使用帮助
show_help() {
    echo "VoiceInk 本地化工具快捷脚本"
    echo ""
    echo "用法:"
    echo "  ./localization-tools/localize.sh [命令]"
    echo ""
    echo "命令:"
    echo "  status    - 显示本地化状态"
    echo "  smart     - 运行智能本地化"
    echo "  sync      - 同步本地化字符串"
    echo "  full      - 执行完整工作流程"
    echo "  master    - 主本地化同步（推荐）"
    echo "  cleanup   - 清理备份文件"
    echo "  setup     - 运行安装程序"
    echo "  help      - 显示此帮助"
    echo ""
    echo "示例:"
    echo "  ./localization-tools/localize.sh status"
    echo "  ./localization-tools/localize.sh full"
}

# 主处理逻辑
case "${1:-help}" in
    "status"|"smart"|"sync"|"full"|"master"|"cleanup")
        echo "🚀 运行: python3 localization-tools/localize.py $1"
        python3 localization-tools/localize.py "$1"
        ;;
    "setup")
        echo "🔧 运行安装程序..."
        python3 localization-tools/setup.py
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ 未知命令: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
