#!/bin/bash
set -euo pipefail

# VoiceInk 一键管理脚本（用于本地化环境）
# 功能：自动构建 whisper.xcframework -> 编译 -> 将 APP 输出到仓库根目录 -> 可选临时签名与运行

# 计算仓库根目录（脚本位于 localization-tools/ 下）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

PROJECT_NAME="VoiceInk"
OUTPUT_APP_NAME="VoiceInk.app"   # 最终在仓库根目录生成的 APP 名称
DERIVED_DATA_DIR="build"

print_help() {
  cat <<EOF
VoiceInk 一键管理脚本

用法: localization-tools/$(basename "$0") [命令] [可选参数]

命令:
  build [--debug]   编译应用（默认 Release，可加 --debug）
  sign              对根目录 ${OUTPUT_APP_NAME} 进行临时签名
  run               运行根目录 ${OUTPUT_APP_NAME}（若未签名则自动签名）
  clean             清理临时文件与根目录 APP
  all               编译 + 签名 + 运行（默认）
  help              显示帮助

说明:
  - 脚本会在缺少 whisper.xcframework 时自动构建 whisper.cpp
  - 编译产物会被复制到仓库根目录，并命名为 ${OUTPUT_APP_NAME}
EOF
}

ensure_env() {
  if [ ! -f "${PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
    echo "❌ 请在仓库根目录执行脚本（当前: $PWD）"
    exit 1
  fi
}

build_whisper_if_needed() {
  local xcframework_path="whisper.cpp/build-apple/whisper.xcframework"
  if [ ! -d "$xcframework_path" ]; then
    echo "📦 未检测到 whisper.xcframework，正在构建..."
    ( cd whisper.cpp && chmod +x build-xcframework.sh && ./build-xcframework.sh )
    echo "✅ whisper.xcframework 构建完成"
  else
    echo "ℹ️  已检测到 whisper.xcframework"
  fi
}

build_app() {
  ensure_env
  build_whisper_if_needed

  local configuration="Release"
  if [[ "${1:-}" == "--debug" ]]; then
    configuration="Debug"
  fi

  echo "🔨 开始编译 (${configuration})..."

  # 清理旧 APP
  if [ -d "$OUTPUT_APP_NAME" ]; then
    echo "🗑️  清理旧的 ${OUTPUT_APP_NAME}..."
    rm -rf "$OUTPUT_APP_NAME"
  fi

  # 编译
  xcodebuild \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${PROJECT_NAME}" \
    -configuration "$configuration" \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    clean build

  echo "🔎 查找编译产物..."
  local product_dir="$DERIVED_DATA_DIR/Build/Products/${configuration}/${PROJECT_NAME}.app"
  if [ -d "$product_dir" ]; then
    cp -R "$product_dir" "$OUTPUT_APP_NAME"
    # 清理派生数据，避免污染仓库
    rm -rf "$DERIVED_DATA_DIR"

    # 容错修复 Info.plist 必需字段
    echo "🔧 修复 Info.plist..."
    plutil -insert CFBundleExecutable -string "${PROJECT_NAME}" "${OUTPUT_APP_NAME}/Contents/Info.plist" 2>/dev/null || true
    plutil -insert CFBundleIdentifier -string "com.prakashjoshipax.${PROJECT_NAME}" "${OUTPUT_APP_NAME}/Contents/Info.plist" 2>/dev/null || true

    echo "✅ 编译完成，产物已输出到: $REPO_ROOT/${OUTPUT_APP_NAME}"
  else
    echo "❌ 未找到编译产物: $product_dir"
    exit 1
  fi
}

sign_app() {
  if [ ! -d "$OUTPUT_APP_NAME" ]; then
    echo "❌ 未找到 $OUTPUT_APP_NAME，请先编译"
    exit 1
  fi
  echo "🔐 正在临时签名 $OUTPUT_APP_NAME..."
  codesign --force --deep --sign - "$OUTPUT_APP_NAME"
  echo "✅ 临时签名完成"
}

run_app() {
  if [ ! -d "$OUTPUT_APP_NAME" ]; then
    echo "❌ 未找到 $OUTPUT_APP_NAME，请先编译"
    exit 1
  fi
  if ! codesign -v "$OUTPUT_APP_NAME" 2>/dev/null; then
    echo "⚠️  应用未签名，正在自动签名..."
    sign_app
  fi
  echo "🚀 启动 ${OUTPUT_APP_NAME}..."
  open "$OUTPUT_APP_NAME"
}

clean_files() {
  echo "🧹 清理临时文件与 APP..."
  rm -rf "$DERIVED_DATA_DIR" "$OUTPUT_APP_NAME"
  echo "✅ 清理完成"
}

main() {
  local cmd="${1:-all}"
  case "$cmd" in
    build)
      shift || true
      build_app "$@"
      ;;
    sign)
      sign_app
      ;;
    run)
      run_app
      ;;
    clean)
      clean_files
      ;;
    all)
      shift || true
      build_app "$@"
      sign_app
      run_app
      ;;
    help|--help|-h)
      print_help
      ;;
    *)
      echo "❌ 未知命令: $cmd"
      print_help
      exit 1
      ;;
  esac
}

main "$@"
