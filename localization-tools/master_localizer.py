#!/usr/bin/env python3
"""
VoiceInk 主本地化管理器
简化的本地化工作流：主要维护中文版本，自动生成英文版本
"""

import os
import re
import shutil
import yaml
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Set, Tuple

class MasterLocalizer:
    def __init__(self, config_path: str = "localization-tools/config.yaml"):
        """初始化主本地化管理器"""
        self.config = self._load_config(config_path)
        self.master_file = self.config.get('output', {}).get('master_strings_file', 'VoiceInk/zh-Hans.lproj/Localizable.strings')
        self.en_file = self.config.get('output', {}).get('en_strings_file', 'VoiceInk/en.lproj/Localizable.strings') 
        self.zh_file = self.config.get('output', {}).get('zh_strings_file', 'VoiceInk/zh-Hans.lproj/Localizable.strings')
        self.backup_path = self.config.get('output', {}).get('tool_backup_path', 'localization-tools/backups/master-strings/')
        
    def _load_config(self, config_path: str) -> dict:
        """加载配置文件"""
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ 无法加载配置文件 {config_path}: {e}")
            return {}
    
    def backup_master_file(self):
        """备份主本地化文件"""
        if not os.path.exists(self.master_file):
            print(f"⚠️  主本地化文件不存在: {self.master_file}")
            return False
        
        # 确保备份目录存在
        os.makedirs(self.backup_path, exist_ok=True)
        
        # 创建带时间戳的备份
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = os.path.join(self.backup_path, f"Localizable_zh_{timestamp}.strings")
        
        try:
            shutil.copy2(self.master_file, backup_file)
            print(f"✅ 主文件已备份: {backup_file}")
            return True
        except Exception as e:
            print(f"❌ 备份失败: {e}")
            return False
    
    def extract_keys_from_master(self) -> Dict[str, str]:
        """从主文件（中文）提取所有键值对"""
        keys = {}
        
        if not os.path.exists(self.master_file):
            print(f"❌ 主文件不存在: {self.master_file}")
            return keys
        
        try:
            with open(self.master_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 匹配键值对: "key" = "value";
            pattern = r'^"([^"]+)"\s*=\s*"([^"]*)";?\s*$'
            for line_num, line in enumerate(content.split('\n'), 1):
                line = line.strip()
                if line and not line.startswith('/*') and not line.startswith('//'):
                    match = re.match(pattern, line)
                    if match:
                        key, value = match.groups()
                        keys[key] = value
                    elif line and not line.startswith('/*') and not line.endswith('*/'):
                        # 检查是否是格式有问题的行
                        if '"' in line and '=' in line:
                            print(f"⚠️  第{line_num}行格式可能有问题: {line[:50]}...")
            
            print(f"📊 从主文件提取了 {len(keys)} 个键值对")
            return keys
            
        except Exception as e:
            print(f"❌ 读取主文件失败: {e}")
            return keys
    
    def generate_english_from_keys(self, keys: Dict[str, str]) -> str:
        """根据中文键值对生成英文版本（键和值相同）"""
        lines = []
        
        # 添加文件头注释
        lines.append("/* VoiceInk English Localization - Auto-generated from Chinese master file */")
        lines.append("")
        
        # 按分类组织键值对
        categories = {
            "主界面导航": [],
            "MenuBarView": [],
            "权限页面": [],
            "设置相关": [],
            "录音相关": [],
            "转录相关": [],
            "模型相关": [],
            "按钮和操作": [],
            "错误和状态消息": [],
            "语言相关": [],
            "其他": []
        }
        
        # 简单的分类逻辑
        for key, value in sorted(keys.items()):
            category = "其他"  # 默认分类
            
            if key in ["Dashboard", "Transcribe Audio", "History", "AI Models", "Enhancement", "Power Mode", "Permissions", "Audio Input", "Dictionary", "Settings", "VoiceInk Pro"]:
                category = "主界面导航"
            elif "Recording" in key or "Record" in key:
                category = "录音相关"
            elif "Transcription" in key or "Transcribe" in key:
                category = "转录相关"
            elif key in ["Save", "Cancel", "Delete", "Edit", "Close", "Open", "Copy", "Paste"]:
                category = "按钮和操作"
            elif "Error" in key or "Warning" in key or "failed" in key:
                category = "错误和状态消息"
            elif key in ["English", "Chinese", "Spanish", "French", "German", "Japanese"]:
                category = "语言相关"
                
            categories[category].append((key, value))
        
        # 生成分类的本地化内容
        for category, items in categories.items():
            if items:
                lines.append(f"/* {category} */")
                for key, value in items:
                    # 英文版本：键和值相同
                    lines.append(f'"{key}" = "{key}";')
                lines.append("")
        
        return '\n'.join(lines)
    
    def write_english_file(self, content: str):
        """写入英文本地化文件"""
        try:
            # 确保目录存在
            os.makedirs(os.path.dirname(self.en_file), exist_ok=True)
            
            with open(self.en_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ 英文文件已生成: {self.en_file}")
            return True
            
        except Exception as e:
            print(f"❌ 写入英文文件失败: {e}")
            return False
    
    def validate_files(self) -> Tuple[bool, List[str]]:
        """验证生成的文件"""
        errors = []
        
        # 检查文件是否存在
        if not os.path.exists(self.zh_file):
            errors.append(f"中文文件不存在: {self.zh_file}")
        if not os.path.exists(self.en_file):
            errors.append(f"英文文件不存在: {self.en_file}")
        
        if errors:
            return False, errors
        
        # 检查键的数量
        zh_keys = set(self.extract_keys_from_master().keys())
        
        try:
            with open(self.en_file, 'r', encoding='utf-8') as f:
                en_content = f.read()
            en_keys = set(re.findall(r'^"([^"]+)"\s*=', en_content, re.MULTILINE))
        except Exception as e:
            errors.append(f"读取英文文件失败: {e}")
            return False, errors
        
        # 比较键的一致性
        missing_in_en = zh_keys - en_keys
        extra_in_en = en_keys - zh_keys
        
        if missing_in_en:
            errors.append(f"英文文件中缺失 {len(missing_in_en)} 个键")
        if extra_in_en:
            errors.append(f"英文文件中多出 {len(extra_in_en)} 个键")
        
        if not errors:
            print(f"✅ 验证通过: 中文({len(zh_keys)}键) 英文({len(en_keys)}键)")
        
        return len(errors) == 0, errors
    
    def sync_to_code(self) -> int:
        """将新的本地化键同步到代码中（调用其他工具）"""
        print("🔄 开始同步本地化键到代码...")
        
        # 调用智能本地化工具（自动确认模式）
        try:
            import subprocess
            result = subprocess.run([
                'python3', 'localization-tools/smart_localize.py', '--auto-confirm'
            ], text=True, cwd='.')
            
            if result.returncode == 0:
                print("✅ 代码同步完成")
                return 0
            else:
                print(f"⚠️  代码同步有警告，返回码: {result.returncode}")
                return 1
        except Exception as e:
            print(f"❌ 代码同步失败: {e}")
            return -1
    
    def run_full_sync(self) -> bool:
        """运行完整的同步流程"""
        print("🚀 VoiceInk 主本地化同步")
        print("=" * 50)
        
        # 1. 备份主文件
        print("📦 步骤1: 备份主文件")
        if not self.backup_master_file():
            return False
        
        # 2. 提取中文键值对
        print("\n📖 步骤2: 提取中文键值对")
        zh_keys = self.extract_keys_from_master()
        if not zh_keys:
            print("❌ 无法提取键值对")
            return False
        
        # 3. 生成英文版本
        print("\n🔄 步骤3: 生成英文版本")
        en_content = self.generate_english_from_keys(zh_keys)
        if not self.write_english_file(en_content):
            return False
        
        # 4. 验证文件
        print("\n🔍 步骤4: 验证文件")
        is_valid, errors = self.validate_files()
        if not is_valid:
            print("❌ 验证失败:")
            for error in errors:
                print(f"  - {error}")
            return False
        
        # 5. 可选：同步到代码
        print("\n💾 步骤5: 同步到代码 (可选)")
        choice = input("是否要同步新的本地化键到代码中？(y/n): ").lower().strip()
        if choice in ['y', 'yes']:
            sync_result = self.sync_to_code()
            if sync_result < 0:
                print("⚠️  代码同步失败，但本地化文件已更新")
        
        print("\n🎉 主本地化同步完成！")
        print(f"📁 中文文件: {self.zh_file}")
        print(f"📁 英文文件: {self.en_file}")
        print(f"💾 备份目录: {self.backup_path}")
        
        return True
    
    def show_status(self):
        """显示当前状态"""
        print("📊 主本地化管理器状态")
        print("=" * 40)
        
        # 检查文件存在性
        print("📁 文件状态:")
        files = [
            ("中文主文件", self.zh_file),
            ("英文文件", self.en_file)
        ]
        
        for name, path in files:
            if os.path.exists(path):
                # 统计键数量
                if path == self.zh_file:
                    keys = self.extract_keys_from_master()
                    count = len(keys)
                else:
                    try:
                        with open(path, 'r', encoding='utf-8') as f:
                            content = f.read()
                        count = len(re.findall(r'^"([^"]+)"\s*=', content, re.MULTILINE))
                    except:
                        count = "?"
                
                print(f"  ✅ {name}: {path} ({count} 键)")
            else:
                print(f"  ❌ {name}: {path} (不存在)")
        
        # 检查备份
        backup_count = 0
        if os.path.exists(self.backup_path):
            backup_files = [f for f in os.listdir(self.backup_path) if f.endswith('.strings')]
            backup_count = len(backup_files)
        
        print(f"\n💾 备份文件: {backup_count} 个")

def main():
    """主函数"""
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
    else:
        command = "status"
    
    localizer = MasterLocalizer()
    
    if command == "sync":
        success = localizer.run_full_sync()
        sys.exit(0 if success else 1)
    elif command == "status":
        localizer.show_status()
    elif command == "generate-en":
        # 只生成英文版本
        zh_keys = localizer.extract_keys_from_master()
        if zh_keys:
            en_content = localizer.generate_english_from_keys(zh_keys)
            if localizer.write_english_file(en_content):
                print("✅ 英文文件已重新生成")
            else:
                sys.exit(1)
        else:
            print("❌ 无法读取中文文件")
            sys.exit(1)
    else:
        print("用法:")
        print("  python3 localization-tools/master_localizer.py status      # 显示状态")
        print("  python3 localization-tools/master_localizer.py sync        # 完整同步")
        print("  python3 localization-tools/master_localizer.py generate-en # 只生成英文")

if __name__ == "__main__":
    main()
