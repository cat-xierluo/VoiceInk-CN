#!/bin/bash

# VoiceInk-CN 一键管理脚本
# 整合编译、签名、运行、清理功能

APP_NAME="VoiceInk-CN"
PROJECT_NAME="VoiceInk"
SCRIPT_NAME="$(basename "$0")"

# 显示帮助信息
show_help() {
    echo "VoiceInk-CN 一键管理脚本"
    echo ""
    echo "用法: ./$SCRIPT_NAME [命令]"
    echo ""
    echo "命令:"
    echo "  build    - 编译应用"
    echo "  sign     - 临时签名"
    echo "  run      - 运行应用"
    echo "  clean    - 清理临时文件"
    echo "  all      - 编译+签名+运行 (默认)"
    echo "  help     - 显示帮助"
    echo ""
    echo "示例:"
    echo "  ./$SCRIPT_NAME        # 编译、签名并运行"
    echo "  ./$SCRIPT_NAME build  # 仅编译"
    echo "  ./$SCRIPT_NAME run    # 仅运行"
}

# 编译应用
build_app() {
    echo "🔨 开始编译..."
    
    # 清理旧的app
    if [ -d "${APP_NAME}.app" ]; then
        echo "🗑️  清理旧的 ${APP_NAME}.app..."
        rm -rf "${APP_NAME}.app"
    fi
    
    # 编译
    xcodebuild clean build \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${PROJECT_NAME}" \
        -configuration Release \
        -derivedDataPath "build" \
        CODE_SIGNING_ALLOWED=NO
    
    if [ $? -ne 0 ]; then
        echo "❌ 编译失败"
        exit 1
    fi
    
    # 复制app
    if [ -d "build/Build/Products/Release/${PROJECT_NAME}.app" ]; then
        cp -R "build/Build/Products/Release/${PROJECT_NAME}.app" "${APP_NAME}.app"
        rm -rf build
        
        # 修复Info.plist，添加缺失的必需字段
        echo "🔧 修复应用配置..."
        plutil -insert CFBundleExecutable -string "VoiceInk" "${APP_NAME}.app/Contents/Info.plist" 2>/dev/null || true
        plutil -insert CFBundleIdentifier -string "com.prakashjoshipax.VoiceInk" "${APP_NAME}.app/Contents/Info.plist" 2>/dev/null || true
        
        echo "✅ 编译完成"
    else
        echo "❌ 未找到编译产物"
        exit 1
    fi
}

# 临时签名
sign_app() {
    if [ ! -d "${APP_NAME}.app" ]; then
        echo "❌ 未找到 ${APP_NAME}.app，请先编译"
        exit 1
    fi
    
    echo "🔐 正在临时签名..."
    codesign --force --deep --sign - "${APP_NAME}.app"
    
    if [ $? -eq 0 ]; then
        echo "✅ 临时签名完成"
    else
        echo "❌ 签名失败"
        exit 1
    fi
}

# 运行应用
run_app() {
    if [ ! -d "${APP_NAME}.app" ]; then
        echo "❌ 未找到 ${APP_NAME}.app，请先编译"
        exit 1
    fi
    
    # 检查签名
    if ! codesign -v "${APP_NAME}.app" 2>/dev/null; then
        echo "⚠️  应用未签名，正在自动签名..."
        sign_app
    fi
    
    echo "🚀 正在启动 ${APP_NAME}..."
    open "${APP_NAME}.app"
}

# 清理临时文件
clean_files() {
    echo "🧹 清理临时文件..."
    rm -rf build
    rm -rf "${APP_NAME}.app"
    echo "✅ 清理完成"
}

# 主逻辑
main() {
    case "${1:-all}" in
        "build")
            build_app
            ;;
        "sign")
            sign_app
            ;;
        "run")
            run_app
            ;;
        "clean")
            clean_files
            ;;
        "all")
            build_app
            sign_app
            run_app
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "❌ 未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
