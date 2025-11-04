#!/usr/bin/env python3
"""
VoiceInk 本地化工具主控脚本
提供统一的本地化工作流程入口
"""

import os
import re
import sys
import shutil
import argparse
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Dict, Tuple, Optional

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
VOICEINK_DIR = PROJECT_ROOT / "VoiceInk"
BASE_STRINGS_PATH = VOICEINK_DIR / "Base.lproj" / "Localizable.strings"
ZH_STRINGS_PATH = VOICEINK_DIR / "zh-Hans.lproj" / "Localizable.strings"
EN_STRINGS_PATH = VOICEINK_DIR / "en.lproj" / "Localizable.strings"
GENERATED_DIR = SCRIPT_DIR / "generated"
EXTRACT_OUTPUT_DIR = GENERATED_DIR / "extract"
BACKUP_DIR = GENERATED_DIR / "backups"
REPLAY_DIR = GENERATED_DIR / "replay"
STRINGS_LINE_PATTERN = re.compile(r'^\s*"(?P<key>[^"]+)"\s*=\s*"(?P<value>.*)";\s*$')

IDENTICAL_ALLOWLIST = {
    "Arc",
    "Base",
    "Brave",
    "Deepgram",
    "Discord",
    "ElevenLabs",
    "Fn",
    "GROQ",
    "Groq",
    "Large v2",
    "Large v3",
    "Large v3 Turbo",
    "Mistral",
    "Opera",
    "Orion",
    "Safari",
    "Tiny",
    "Vivaldi",
    "VoiceInk",
    "VoiceInk Pro",
    "ggml-base",
    "ggml-large-v2",
    "ggml-large-v3",
    "ggml-large-v3-turbo",
    "ggml-large-v3-turbo-q5_0",
    "ggml-tiny",
    "large-v3-turbo",
    "nova-2",
    "voxtral-mini-2507",
    "whisper-1",
    "whisper-large-v3-turbo",
    "www.",
    "v\\(appVersion)",
    "\\(icon).fill",
    "\\(number)",
    "\\(priority + 1)",
    "1.5 GiB",
    "142 MiB",
    "2.9 GiB",
    "547 MiB",
    "75 MiB",
    "Bonjour, comment allez-vous? Ravi de vous rencontrer.",
    "Ciao, come stai? Piacere di conoscerti.",
    "Hallo, hoe gaat het? Aangenaam kennis te maken.",
    "Hallo, wie geht es dir? Schön dich kennenzulernen.",
}

def check_dependencies(command: str) -> bool:
    """检查依赖项"""
    try:
        import yaml
    except ImportError:
        print("❌ 缺少依赖: pyyaml")
        print("请安装: pip install pyyaml")
        return False
    
    # 检查必要文件
    required_files = [
        "localization-tools/config.yaml",
        "localization-tools/localizer.py",
        "localization-tools/sync_strings.py"
    ]
    
    for file_path in required_files:
        if not os.path.exists(file_path):
            print(f"❌ 缺少必要文件: {file_path}")
            return False

    if command in {"extract", "full"}:
        if shutil.which("xcrun") is None:
            print("⚠️ 未检测到 xcrun，可在 macOS + Xcode Command Line Tools 环境运行以启用自动提取 Base 字符串。")
            # 不阻断流程，后续函数会给出更详细提示
    
    return True

def parse_strings_file(path: Path) -> Tuple[Dict[str, str], Dict[str, str], list]:
    """解析 .strings 文件，返回 (键值映射, 注释映射, 重复键列表)"""
    entries: Dict[str, str] = {}
    comments: Dict[str, str] = {}
    duplicates: list = []

    if not path.exists():
        return entries, comments, duplicates

    current_comment = None
    try:
        with path.open('r', encoding='utf-8') as f:
            for line_no, raw_line in enumerate(f, 1):
                line = raw_line.strip()
                if not line or line.startswith("//"):
                    continue
                if line.startswith("/*") and line.endswith("*/"):
                    current_comment = line.strip("/* ").rstrip("*/").strip()
                    continue

                match = STRINGS_LINE_PATTERN.match(line)
                if match:
                    key = match.group("key")
                    value = match.group("value")
                    if key in entries:
                        duplicates.append(key)
                    entries[key] = value
                    if current_comment:
                        comments[key] = current_comment
                        current_comment = None
    except Exception as exc:
        print(f"❌ 解析字符串文件失败 {path}: {exc}")

    return entries, comments, duplicates


def is_identical_allowed(key: str, value: str) -> bool:
    if key in IDENTICAL_ALLOWLIST:
        return True
    if any(ord(ch) > 127 for ch in value):
        return True
    if "%" in key or "%" in value:
        return True
    if "\\" in key or "\\" in value:
        return True
    return False

def summarize_keys(keys, comments: Dict[str, str], limit: int = 10) -> None:
    """打印缺失/多余键的概要"""
    for key in list(keys)[:limit]:
        comment = comments.get(key, "")
        note = f" // {comment}" if comment else ""
        print(f"   - {key}{note}")
    if len(keys) > limit:
        print(f"   ... 还有 {len(keys) - limit} 个键")

def extract_base_strings() -> bool:
    """使用 xcrun extractLocStrings 更新 Base.lproj 字符串"""
    project_path = PROJECT_ROOT / "VoiceInk.xcodeproj"
    if not project_path.exists():
        print("❌ 未找到 VoiceInk.xcodeproj，无法提取 Base 本地化资源")
        return False

    if shutil.which("xcrun") is None:
        print("❌ 未检测到 xcrun，请在安装了 Xcode 的 macOS 环境运行该命令")
        return False

    EXTRACT_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("🛠️ 正在使用 xcrun extractLocStrings 生成 Base 字符串...")
    command_variants = [
        [
            "xcrun",
            "extractLocStrings",
            "--project",
            str(project_path),
            "--output-path",
            str(EXTRACT_OUTPUT_DIR),
            "--type",
            "strings",
        ],
        [
            "xcrun",
            "extractLocStrings",
            "--project",
            str(project_path),
            "--output",
            str(EXTRACT_OUTPUT_DIR),
            "--type",
            "strings",
        ],
        [
            "xcrun",
            "extractLocStrings",
            "-o",
            str(EXTRACT_OUTPUT_DIR),
            str(project_path),
        ],
    ]

    last_error = ""
    for cmd in command_variants:
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        except FileNotFoundError:
            print("❌ 无法执行 xcrun，请确认 Xcode Command Line Tools 已安装")
            return False

        if result.returncode == 0:
            break
        last_error = (result.stderr or result.stdout or "").strip()
    else:
        print("❌ extractLocStrings 执行失败")
        if last_error:
            print(last_error)
        print("   ▶️ 可尝试在终端手动执行：xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug build")
        print("   或者在安装完整 Xcode 后重新运行 `python localization-tools/localize.py extract`")
        return False

    extracted_base = EXTRACT_OUTPUT_DIR / "Base.lproj"
    if not extracted_base.exists():
        print("⚠️ 提取完成但未找到 Base.lproj 目录，请检查输出:", EXTRACT_OUTPUT_DIR)
        return False

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    if BASE_STRINGS_PATH.exists():
        backup_path = BACKUP_DIR / f"Localizable.strings.{timestamp}.bak"
        shutil.copy2(BASE_STRINGS_PATH, backup_path)
        print(f"🗂️ 已备份现有 Base 字符串到 {backup_path}")

    BASE_STRINGS_PATH.parent.mkdir(parents=True, exist_ok=True)
    try:
        for item in extracted_base.iterdir():
            target_path = BASE_STRINGS_PATH.parent / item.name
            if item.is_dir():
                shutil.copytree(item, target_path, dirs_exist_ok=True)
            else:
                shutil.copy2(item, target_path)
        print(f"✅ Base 字符串已更新：{BASE_STRINGS_PATH.parent}")
    except Exception as exc:
        print(f"❌ 拷贝提取结果失败: {exc}")
        return False

    return True

def copy_into(source: Path, destination: Path) -> None:
    """复制文件或目录到目标位置"""
    if source.is_dir():
        shutil.copytree(source, destination, dirs_exist_ok=True)
    else:
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)

def run_replay(source_root: Path, destination: Optional[Path] = None) -> Optional[Path]:
    """将上游源码复制到工作目录并应用本地化补丁"""
    if not source_root.exists():
        print(f"❌ 指定的上游路径不存在：{source_root}")
        return None
    if not (source_root / "VoiceInk").exists():
        print(f"❌ 在 {source_root} 下未找到 VoiceInk 目录，请确认这是上游项目根目录。")
        return None

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    destination = destination or (REPLAY_DIR / f"VoiceInk-{timestamp}")

    if destination.exists():
        print(f"⚠️ 目标目录已存在：{destination}，将写入其下的子目录。")
        destination = destination / f"VoiceInk-{timestamp}"

    print(f"🗂️ 复制上游代码：{source_root} -> {destination}")
    shutil.copytree(source_root, destination)

    overlay_items = [
        (VOICEINK_DIR / "Base.lproj", destination / "VoiceInk" / "Base.lproj"),
        (VOICEINK_DIR / "zh-Hans.lproj", destination / "VoiceInk" / "zh-Hans.lproj"),
        (VOICEINK_DIR / "L10n.swift", destination / "VoiceInk" / "L10n.swift"),
        (VOICEINK_DIR / "Views" / "ContentView.swift", destination / "VoiceInk" / "Views" / "ContentView.swift"),
        (VOICEINK_DIR / "Views" / "LicenseManagementView.swift", destination / "VoiceInk" / "Views" / "LicenseManagementView.swift"),
        (VOICEINK_DIR / "VoiceInk.swift", destination / "VoiceInk" / "VoiceInk.swift"),
        (VOICEINK_DIR / "WindowManager.swift", destination / "VoiceInk" / "WindowManager.swift"),
        (PROJECT_ROOT / "localization-tools", destination / "localization-tools"),
    ]

    for source, target in overlay_items:
        if not source.exists():
            print(f"⚠️ 跳过缺失的资源：{source}")
            continue
        copy_into(source, target)

    print("🔁 运行本地化状态检查（带报告）...")
    status_cmd = [sys.executable, "localization-tools/localize.py", "status", "-r"]
    subprocess.run(status_cmd, cwd=destination, check=False)

    print(f"✅ 重放完成，生成目录：{destination}")
    return destination

def show_status(diff_limit: int = 12, report_path: Optional[Path] = None) -> Dict[str, object]:
    """显示当前本地化状态，并可选输出到报告文件"""
    print("📊 VoiceInk 本地化状态")
    print("=" * 40)

    base_entries, base_comments, base_duplicates = parse_strings_file(BASE_STRINGS_PATH)
    en_entries, en_comments, en_duplicates = parse_strings_file(EN_STRINGS_PATH)
    zh_entries, zh_comments, zh_duplicates = parse_strings_file(ZH_STRINGS_PATH)

    base_source = "Base.lproj"
    effective_entries = base_entries
    effective_comments = base_comments
    effective_duplicates = base_duplicates

    if not effective_entries and en_entries:
        effective_entries = en_entries
        effective_comments = en_comments
        effective_duplicates = en_duplicates
        base_source = "en.lproj（回退）"
        print(f"ℹ️ 使用 en.lproj 作为比对基准，因为 Base.lproj 不存在或为空：{EN_STRINGS_PATH}")
    elif en_entries and len(en_entries) > len(effective_entries) + 20:
        effective_entries = en_entries
        effective_comments = en_comments
        effective_duplicates = en_duplicates
        base_source = "en.lproj（比 Base 更完整）"
        print(f"ℹ️ Base.lproj 键数显著少于 en.lproj，将使用后者比对：Base={len(base_entries)}，en={len(en_entries)}")

    if not effective_entries:
        print(f"⚠️ 未找到可用的基准字符串文件：{BASE_STRINGS_PATH} 或 {EN_STRINGS_PATH}")
    if not zh_entries:
        print(f"⚠️ 未找到或未能解析中文字符串文件：{ZH_STRINGS_PATH}")

    base_keys = set(effective_entries.keys())
    zh_keys = set(zh_entries.keys())

    status_data = {
        "base_source": base_source,
        "base_path": str(BASE_STRINGS_PATH if "Base" in base_source else EN_STRINGS_PATH),
        "base_key_count": len(effective_entries),
        "zh_key_count": len(zh_entries),
        "missing_in_zh": sorted(base_keys - zh_keys),
        "extra_in_zh": sorted(zh_keys - base_keys),
        "untranslated": sorted(
            key
            for key in base_keys & zh_keys
            if zh_entries[key] == effective_entries.get(key)
            and not is_identical_allowed(key, zh_entries[key])
        ),
        "empty_values": sorted(key for key, value in zh_entries.items() if value.strip() == ""),
        "base_duplicates": sorted(set(effective_duplicates)),
        "zh_duplicates": sorted(set(zh_duplicates)),
    }

    print(f"📁 字符串键统计：")
    print(f"   基准来源：{status_data['base_source']} ({status_data['base_path']})")
    print(f"   基准键数：{status_data['base_key_count']}")
    print(f"   中文键数：{status_data['zh_key_count']}")
    diff = status_data["base_key_count"] - status_data["zh_key_count"]
    if diff == 0:
        print("   ✅ 键数量一致")
    else:
        sign = "多" if diff < 0 else "少"
        print(f"   ⚠️ 键数量不一致（中文比基准 {sign} {abs(diff)} 个）")

    if status_data["missing_in_zh"]:
        print(f"\n❗ 中文缺失 {len(status_data['missing_in_zh'])} 个键：")
        summarize_keys(status_data["missing_in_zh"], effective_comments or zh_comments, diff_limit)
    if status_data["extra_in_zh"]:
        print(f"\nℹ️ 中文多出 {len(status_data['extra_in_zh'])} 个键（可能已弃用）：")
        summarize_keys(status_data["extra_in_zh"], zh_comments, diff_limit)
    if status_data["untranslated"]:
        print(f"\n⚠️ 中文与基准内容一致的键 {len(status_data['untranslated'])} 个（可能未翻译或需人工确认）：")
        summarize_keys(status_data["untranslated"], zh_comments, diff_limit)
    if status_data["empty_values"]:
        print(f"\n⚠️ 中文为空值的键 {len(status_data['empty_values'])} 个：")
        summarize_keys(status_data["empty_values"], zh_comments, diff_limit)

    if status_data["base_duplicates"]:
        print(f"\n⚠️ 基准存在重复键 {len(status_data['base_duplicates'])} 个")
    if status_data["zh_duplicates"]:
        print(f"\n⚠️ 中文存在重复键 {len(status_data['zh_duplicates'])} 个")

    def count_localized_strings() -> int:
        count = 0
        for root, _, files in os.walk(VOICEINK_DIR):
            for file in files:
                if file.endswith('.swift'):
                    file_path = Path(root) / file
                    try:
                        with file_path.open('r', encoding='utf-8') as handle:
                            content = handle.read()
                        matches = re.findall(r'NSLocalizedString\(', content)
                        count += len(matches)
                    except Exception:
                        continue
        return count

    localized_count = count_localized_strings()
    status_data["localized_calls"] = localized_count

    print(f"\n🔧 代码扫描：")
    print(f"   NSLocalizedString 调用计数：{localized_count}")

    backup_files = []
    for root, _, files in os.walk(PROJECT_ROOT):
        for file in files:
            if '.backup' in file and (file.endswith('.swift') or file.endswith('.strings')):
                backup_files.append(os.path.join(root, file))

    status_data["backup_files"] = backup_files

    if backup_files:
        print(f"\n💾 备份检测：发现 {len(backup_files)} 个 *.backup 文件")
        for backup in backup_files[:5]:
            print(f"   {backup}")
        if len(backup_files) > 5:
            print(f"   ... 还有 {len(backup_files) - 5} 个")

    if report_path:
        report_path = GENERATED_DIR / "reports" / report_path if not Path(report_path).is_absolute() else Path(report_path)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with report_path.open("w", encoding="utf-8") as report_file:
            report_file.write(f"# 本地化状态报告\n\n生成时间：{timestamp}\n\n")
            report_file.write(f"- 基准来源：{status_data['base_source']} ({status_data['base_path']})\n")
            report_file.write(f"- 基准键数：{status_data['base_key_count']}\n")
            report_file.write(f"- 中文键数：{status_data['zh_key_count']}\n")
            report_file.write(f"- NSLocalizedString 调用：{localized_count}\n")
            report_file.write(f"- 备份文件：{len(backup_files)} 个\n\n")

            def write_section(title: str, items: list, comments_dict: Dict[str, str]):
                if not items:
                    return
                report_file.write(f"## {title}（{len(items)}）\n")
                for key in items:
                    comment = comments_dict.get(key, "")
                    suffix = f" // {comment}" if comment else ""
                    report_file.write(f"- `{key}`{suffix}\n")
                report_file.write("\n")

            write_section("中文缺失键", status_data["missing_in_zh"], effective_comments or zh_comments)
            write_section("中文多余键", status_data["extra_in_zh"], zh_comments)
            write_section("未翻译键", status_data["untranslated"], zh_comments)
            write_section("中文为空键", status_data["empty_values"], zh_comments)
            write_section("基准重复键", status_data["base_duplicates"], effective_comments or {})
            write_section("中文重复键", status_data["zh_duplicates"], zh_comments)

        print(f"\n📝 状态报告已保存至：{report_path}")

    return status_data

def run_smart_localize():
    """运行智能本地化"""
    print("🚀 启动智能本地化...")
    try:
        from localizer import SmartLocalizer
        localizer = SmartLocalizer()
        report = localizer.run()
        return True
    except Exception as e:
        print(f"❌ 智能本地化失败: {e}")
        return False

def run_sync_strings():
    """运行字符串同步"""
    print("🔄 启动字符串同步...")
    try:
        from sync_strings import StringsSyncer
        syncer = StringsSyncer()
        result = syncer.sync()
        return True
    except Exception as e:
        print(f"❌ 字符串同步失败: {e}")
        return False

def run_master_sync():
    """运行主本地化同步"""
    print("🎯 启动主本地化同步...")
    try:
        from master_localizer import MasterLocalizer
        localizer = MasterLocalizer()
        result = localizer.run_full_sync()
        return result
    except Exception as e:
        print(f"❌ 主本地化同步失败: {e}")
        return False

def run_full_workflow(report_path: Optional[Path] = None):
    """运行完整的本地化工作流程"""
    print("🎯 执行完整本地化工作流程")
    print("=" * 50)
    
    # 步骤1: 显示当前状态
    print("\n📊 步骤1: 检查当前状态")
    show_status()

    # 步骤2: 更新 Base 字符串资源
    print("\n🛠️ 步骤2: 提取最新 Base 字符串")
    extracted = extract_base_strings()
    if not extracted:
        print("⚠️ 未能自动更新 Base.lproj，请手动运行 `xcrun extractLocStrings` 或确认 Xcode 环境。")
    
    # 步骤3: 智能本地化
    print("\n🤖 步骤3: 智能本地化处理")
    if not run_smart_localize():
        print("❌ 智能本地化失败，停止流程")
        return False
    
    # 步骤4: 同步字符串
    print("\n🔄 步骤4: 同步本地化字符串")
    if not run_sync_strings():
        print("❌ 字符串同步失败，停止流程")
        return False
    
    # 步骤5: 显示最终状态
    print("\n📊 步骤5: 检查最终状态")
    show_status(report_path=report_path)
    
    print("\n🎉 完整工作流程执行完成！")
    return True

def cleanup_backups():
    """清理备份文件"""
    print("🧹 清理备份文件...")
    
    backup_files = []
    for root, dirs, files in os.walk('.'):
        for file in files:
            if '.backup' in file and (file.endswith('.swift') or file.endswith('.strings')):
                backup_files.append(os.path.join(root, file))
    
    if not backup_files:
        print("✅ 没有找到备份文件")
        return
    
    print(f"发现 {len(backup_files)} 个备份文件:")
    for backup in backup_files[:10]:  # 显示前10个
        print(f"  {backup}")
    if len(backup_files) > 10:
        print(f"  ... 还有 {len(backup_files) - 10} 个")
    
    choice = input("\n是否删除这些备份文件？(y/n): ").lower().strip()
    if choice in ['y', 'yes']:
        deleted = 0
        for backup in backup_files:
            try:
                os.remove(backup)
                deleted += 1
            except Exception as e:
                print(f"删除失败 {backup}: {e}")
        
        print(f"✅ 已删除 {deleted} 个备份文件")
    else:
        print("取消删除操作")

def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description="VoiceInk 本地化工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  python localize.py extract        # 提取最新 Base.lproj 字符串
  python localize.py status           # 显示本地化状态
  python localize.py smart            # 运行智能本地化
  python localize.py sync             # 同步本地化字符串
  python localize.py full             # 执行完整工作流程
  python localize.py cleanup          # 清理备份文件
  python localize.py replay --source ../VoiceInk-upstream   # 复制上游代码并应用本地化补丁
        """
    )

    parser.add_argument(
        'command',
        choices=['extract', 'status', 'smart', 'sync', 'full', 'master', 'cleanup', 'replay'],
        help='要执行的命令'
    )
    parser.add_argument(
        '-r',
        '--report',
        nargs='?',
        const='',
        help='在执行 status/full 时输出 Markdown 报告，可指定路径（默认写入 localization-tools/generated/reports/）'
    )
    parser.add_argument(
        '--source',
        help='replay 命令使用的上游项目根目录'
    )
    parser.add_argument(
        '--dest',
        help='replay 命令生成的目标目录（默认位于 localization-tools/generated/replay/）'
    )
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    args = parser.parse_args()
    
    now = datetime.now()
    print(f"🚀 VoiceInk 本地化工具 - {now.strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # 检查依赖
    if not check_dependencies(args.command):
        print("❌ 依赖检查失败")
        return 1
    
    # 确保在正确的目录中
    if not VOICEINK_DIR.exists():
        print("❌ 未找到 VoiceInk 目录，请在项目根目录运行该脚本")
        return 1
    if not BASE_STRINGS_PATH.parent.exists() and not (VOICEINK_DIR / "en.lproj").exists():
        print("⚠️ 未检测到 Base.lproj 或 en.lproj，请确认本地化资源路径是否存在")
        return 1
    
    report_path: Optional[Path] = None
    if args.report is not None and args.command in {"status", "full"}:
        if args.report == "":
            report_path = Path(f"status-{now.strftime('%Y%m%d-%H%M%S')}.md")
        else:
            report_path = Path(args.report)
    
    # 执行命令
    try:
        if args.command == 'extract':
            extract_base_strings()
        elif args.command == 'status':
            show_status(report_path=report_path)
        elif args.command == 'smart':
            run_smart_localize()
        elif args.command == 'sync':
            run_sync_strings()
        elif args.command == 'full':
            run_full_workflow(report_path=report_path)
        elif args.command == 'master':
            run_master_sync()
        elif args.command == 'cleanup':
            cleanup_backups()
        elif args.command == 'replay':
            if not args.source:
                print("❌ replay 命令需要指定 --source")
                return 1
            dest_path = Path(args.dest).resolve() if args.dest else None
            run_replay(Path(args.source).resolve(), dest_path)

        return 0
        
    except KeyboardInterrupt:
        print("\n❌ 用户中断操作")
        return 1
    except Exception as e:
        print(f"❌ 执行出错: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
