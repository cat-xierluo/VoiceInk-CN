#!/usr/bin/env python3
"""
VoiceInk 本地化工具主控脚本
提供统一的本地化工作流程入口
"""

import os
import sys
import argparse
from datetime import datetime

def check_dependencies():
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
        "localization-tools/smart_localize.py",
        "localization-tools/sync_strings.py"
    ]
    
    for file_path in required_files:
        if not os.path.exists(file_path):
            print(f"❌ 缺少必要文件: {file_path}")
            return False
    
    return True

def show_status():
    """显示当前本地化状态"""
    print("📊 VoiceInk 本地化状态")
    print("=" * 40)
    
    # 检查本地化文件
    en_file = "VoiceInk/en.lproj/Localizable.strings"
    zh_file = "VoiceInk/zh-Hans.lproj/Localizable.strings"
    
    def count_keys(file_path):
        if not os.path.exists(file_path):
            return 0
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            import re
            keys = re.findall(r'^"([^"]+)"\s*=.*$', content, re.MULTILINE)
            return len(keys)
        except:
            return 0
    
    en_count = count_keys(en_file)
    zh_count = count_keys(zh_file)
    
    print(f"📁 本地化文件:")
    print(f"   英文: {en_file} ({en_count} 个键)")
    print(f"   中文: {zh_file} ({zh_count} 个键)")
    
    if en_count == zh_count:
        print("✅ 键数量同步")
    else:
        print(f"⚠️  键数量不同步 (差异: {abs(en_count - zh_count)})")
    
    # 检查代码中的本地化使用情况
    def count_localized_strings():
        count = 0
        for root, dirs, files in os.walk('VoiceInk'):
            for file in files:
                if file.endswith('.swift'):
                    file_path = os.path.join(root, file)
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                        import re
                        matches = re.findall(r'NSLocalizedString\(', content)
                        count += len(matches)
                    except:
                        pass
        return count
    
    localized_count = count_localized_strings()
    print(f"\n🔧 代码状态:")
    print(f"   NSLocalizedString 调用: {localized_count} 处")
    
    # 检查备份文件
    backup_files = []
    for root, dirs, files in os.walk('.'):
        for file in files:
            if '.backup' in file and (file.endswith('.swift') or file.endswith('.strings')):
                backup_files.append(os.path.join(root, file))
    
    if backup_files:
        print(f"\n💾 备份文件: {len(backup_files)} 个")
        for backup in backup_files[:5]:  # 只显示前5个
            print(f"   {backup}")
        if len(backup_files) > 5:
            print(f"   ... 还有 {len(backup_files) - 5} 个")

def run_smart_localize():
    """运行智能本地化"""
    print("🚀 启动智能本地化...")
    try:
        from smart_localize import SmartLocalizer
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

def run_full_workflow():
    """运行完整的本地化工作流程"""
    print("🎯 执行完整本地化工作流程")
    print("=" * 50)
    
    # 步骤1: 显示当前状态
    print("\n📊 步骤1: 检查当前状态")
    show_status()
    
    # 步骤2: 智能本地化
    print("\n🤖 步骤2: 智能本地化处理")
    if not run_smart_localize():
        print("❌ 智能本地化失败，停止流程")
        return False
    
    # 步骤3: 同步字符串
    print("\n🔄 步骤3: 同步本地化字符串")
    if not run_sync_strings():
        print("❌ 字符串同步失败，停止流程")
        return False
    
    # 步骤4: 显示最终状态
    print("\n📊 步骤4: 检查最终状态")
    show_status()
    
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
  python localize.py status           # 显示本地化状态
  python localize.py smart            # 运行智能本地化
  python localize.py sync             # 同步本地化字符串
  python localize.py full             # 执行完整工作流程
  python localize.py cleanup          # 清理备份文件
        """
    )
    
    parser.add_argument(
        'command',
        choices=['status', 'smart', 'sync', 'full', 'master', 'cleanup'],
        help='要执行的命令'
    )
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    args = parser.parse_args()
    
    print(f"🚀 VoiceInk 本地化工具 - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # 检查依赖
    if not check_dependencies():
        print("❌ 依赖检查失败")
        return 1
    
    # 确保在正确的目录中
    if not os.path.exists('VoiceInk') or not os.path.exists('VoiceInk/en.lproj'):
        print("❌ 请在VoiceInk项目根目录中运行此脚本")
        return 1
    
    # 执行命令
    try:
        if args.command == 'status':
            show_status()
        elif args.command == 'smart':
            run_smart_localize()
        elif args.command == 'sync':
            run_sync_strings()
        elif args.command == 'full':
            run_full_workflow()
        elif args.command == 'master':
            run_master_sync()
        elif args.command == 'cleanup':
            cleanup_backups()
        
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
