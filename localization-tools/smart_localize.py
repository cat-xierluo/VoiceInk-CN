#!/usr/bin/env python3
"""
VoiceInk 智能本地化脚本 v2.0
改进版本，避免过度替换，只处理用户界面相关的字符串
"""

import re
import os
import yaml
import glob
import logging
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional

class SmartLocalizer:
    def __init__(self, config_path: str = "localization-tools/config.yaml"):
        """初始化智能本地化器"""
        self.config = self._load_config(config_path)
        self._setup_logging()
        self.processed_files = []
        self.backup_files = []
        
    def _load_config(self, config_path: str) -> dict:
        """加载配置文件"""
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ 无法加载配置文件 {config_path}: {e}")
            return {}
    
    def _setup_logging(self):
        """设置日志"""
        log_dir = Path("localization-tools/logs")
        log_dir.mkdir(exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(self.config.get('output', {}).get('log_file', 'localization.log')),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def find_target_files(self) -> List[str]:
        """根据配置查找需要处理的文件"""
        target_files = []
        include_paths = self.config.get('include_paths', [])
        exclude_files = self.config.get('exclude_files', [])
        
        for pattern in include_paths:
            files = glob.glob(pattern, recursive=True)
            target_files.extend(files)
        
        # 排除不需要的文件
        filtered_files = []
        for file_path in target_files:
            should_exclude = False
            for exclude_pattern in exclude_files:
                if glob.fnmatch.fnmatch(file_path, exclude_pattern):
                    should_exclude = True
                    break
            if not should_exclude and file_path.endswith('.swift'):
                filtered_files.append(file_path)
        
        return sorted(list(set(filtered_files)))
    
    def is_localizable_string(self, string: str, context: str) -> bool:
        """判断字符串是否应该被本地化"""
        # 检查字符串模式排除规则
        exclude_patterns = self.config.get('exclude_string_patterns', [])
        for pattern in exclude_patterns:
            if re.search(pattern, string):
                return False
        
        # 检查上下文排除规则
        exclude_contexts = self.config.get('exclude_contexts', [])
        for context_pattern in exclude_contexts:
            if re.search(context_pattern, context):
                return False
        
        # 基本条件：长度大于2，包含字母，不是纯技术术语
        if len(string) < 3:
            return False
        
        if not re.search(r'[a-zA-Z]', string):
            return False
        
        # 排除纯数字、纯符号等
        if re.match(r'^[0-9\s\-_.,:;!?]+$', string):
            return False
        
        # 排除已经本地化的内容
        if 'NSLocalizedString' in context:
            return False
        
        return True
    
    def extract_localizable_strings(self, file_path: str) -> List[Tuple[str, str, int]]:
        """从文件中提取可本地化的字符串"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            localizable_strings = []
            lines = content.split('\n')
            
            # 查找双引号字符串
            pattern = r'"([A-Z][a-zA-Z\s:.,!?\'-]{3,})"'
            
            for line_num, line in enumerate(lines, 1):
                matches = re.finditer(pattern, line)
                for match in matches:
                    string = match.group(1)
                    # 获取上下文（前后各50个字符）
                    start = max(0, match.start() - 50)
                    end = min(len(line), match.end() + 50)
                    context = line[start:end]
                    
                    if self.is_localizable_string(string, context):
                        localizable_strings.append((string, context, line_num))
            
            return localizable_strings
            
        except Exception as e:
            self.logger.error(f"提取字符串时出错 {file_path}: {e}")
            return []
    
    def create_backup(self, file_path: str) -> bool:
        """创建文件备份"""
        try:
            backup_suffix = self.config.get('output', {}).get('backup_suffix', '.backup')
            backup_path = f"{file_path}{backup_suffix}"
            shutil.copy2(file_path, backup_path)
            self.backup_files.append(backup_path)
            return True
        except Exception as e:
            self.logger.error(f"创建备份失败 {file_path}: {e}")
            return False
    
    def localize_file(self, file_path: str) -> int:
        """本地化单个文件"""
        try:
            # 创建备份
            if not self.create_backup(file_path):
                return 0
            
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            changes = 0
            
            # 获取通用本地化映射
            common_localizations = self.config.get('common_localizations', {})
            
            # 应用本地化替换
            for string, (key, comment) in common_localizations.items():
                # 构建精确的替换模式，避免过度替换
                # 只替换在合适上下文中的字符串
                patterns = [
                    # Button, Text, Label等UI组件中的字符串
                    f'(Button|Text|Label|Toggle|Menu)\\s*\\(\\s*"{re.escape(string)}"',
                    # title, description等属性中的字符串
                    f'(title|description|buttonTitle):\\s*"{re.escape(string)}"',
                    # 直接的字符串赋值
                    f'=\\s*"{re.escape(string)}"(?!\\s*\\+)',  # 避免字符串拼接
                ]
                
                for pattern in patterns:
                    replacement_pattern = f'(Button|Text|Label|Toggle|Menu)\\s*\\(\\s*"{re.escape(string)}"'
                    if re.search(replacement_pattern, content, re.IGNORECASE):
                        # 只有当模式匹配时才替换
                        new_content = re.sub(
                            f'"{re.escape(string)}"(?!\\s*,\\s*comment:)',  # 避免重复本地化
                            f'NSLocalizedString("{key}", comment: "{comment}")',
                            content
                        )
                        if new_content != content:
                            content = new_content
                            changes += 1
                            break
            
            # 写回文件
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                self.processed_files.append(file_path)
                self.logger.info(f"✅ {file_path}: {changes} 处修改")
                return changes
            else:
                # 如果没有修改，删除备份
                backup_path = f"{file_path}{self.config.get('output', {}).get('backup_suffix', '.backup')}"
                if os.path.exists(backup_path):
                    os.remove(backup_path)
                    self.backup_files.remove(backup_path)
                return 0
                
        except Exception as e:
            self.logger.error(f"处理文件失败 {file_path}: {e}")
            return 0
    
    def collect_new_strings(self) -> Set[str]:
        """收集所有需要添加到本地化文件的新字符串"""
        all_keys = set()
        target_files = self.find_target_files()
        
        for file_path in target_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # 查找NSLocalizedString调用
                pattern = r'NSLocalizedString\\("([^"]+)",\\s*comment:\\s*"[^"]*"\\)'
                matches = re.findall(pattern, content)
                all_keys.update(matches)
                
            except Exception as e:
                self.logger.error(f"收集字符串时出错 {file_path}: {e}")
        
        return all_keys
    
    def update_localization_files(self, new_keys: Set[str]):
        """更新本地化文件"""
        # 这里可以添加逻辑来更新.strings文件
        # 暂时先记录需要添加的新键
        if new_keys:
            self.logger.info(f"发现 {len(new_keys)} 个新的本地化键需要手动添加到.strings文件")
            for key in sorted(new_keys):
                self.logger.info(f"  \"{key}\"")
    
    def rollback(self):
        """回滚所有更改"""
        rollback_count = 0
        for backup_path in self.backup_files:
            try:
                original_path = backup_path.replace(
                    self.config.get('output', {}).get('backup_suffix', '.backup'),
                    ''
                )
                shutil.move(backup_path, original_path)
                rollback_count += 1
            except Exception as e:
                self.logger.error(f"回滚失败 {backup_path}: {e}")
        
        self.logger.info(f"回滚了 {rollback_count} 个文件")
    
    def run(self) -> dict:
        """运行本地化处理"""
        start_time = datetime.now()
        self.logger.info("🚀 开始智能本地化处理")
        
        # 查找目标文件
        target_files = self.find_target_files()
        self.logger.info(f"📁 找到 {len(target_files)} 个目标文件")
        
        # 处理前统计
        before_strings = set()
        for file_path in target_files:
            strings = self.extract_localizable_strings(file_path)
            before_strings.update([s[0] for s in strings])
        
        self.logger.info(f"📝 处理前发现 {len(before_strings)} 个可本地化字符串")
        
        # 批量处理文件
        total_changes = 0
        processed_count = 0
        
        for file_path in target_files:
            changes = self.localize_file(file_path)
            if changes > 0:
                total_changes += changes
                processed_count += 1
            else:
                self.logger.info(f"⏭️  {file_path}: 无需修改")
        
        # 处理后统计
        after_strings = set()
        for file_path in target_files:
            strings = self.extract_localizable_strings(file_path)
            after_strings.update([s[0] for s in strings])
        
        # 收集新的本地化键
        new_keys = self.collect_new_strings()
        
        end_time = datetime.now()
        duration = end_time - start_time
        
        # 生成报告
        report = {
            'duration': duration.total_seconds(),
            'target_files': len(target_files),
            'processed_files': processed_count,
            'total_changes': total_changes,
            'strings_before': len(before_strings),
            'strings_after': len(after_strings),
            'new_localization_keys': len(new_keys),
            'backup_files': len(self.backup_files)
        }
        
        self.logger.info(f"🎉 本地化处理完成！")
        self.logger.info(f"   ⏱️  耗时: {duration.total_seconds():.2f}秒")
        self.logger.info(f"   📁 处理了 {len(target_files)} 个文件")
        self.logger.info(f"   ✏️  修改了 {processed_count} 个文件")
        self.logger.info(f"   🔄 总共 {total_changes} 处修改")
        self.logger.info(f"   📉 剩余 {len(after_strings)} 个未处理字符串")
        self.logger.info(f"   🔑 新增 {len(new_keys)} 个本地化键")
        
        return report

def main():
    """主函数"""
    import sys
    
    # 检查是否为非交互模式
    auto_confirm = len(sys.argv) > 1 and sys.argv[1] == '--auto-confirm'
    
    print("🚀 VoiceInk 智能本地化工具 v2.0")
    print("=" * 50)
    
    localizer = SmartLocalizer()
    
    try:
        report = localizer.run()
        
        if auto_confirm:
            print("\n✅ 自动确认模式：处理完成！")
            return
        
        # 询问是否满意结果
        while True:
            choice = input("\n是否满意本次处理结果？(y/n/r-rollback): ").lower().strip()
            if choice in ['y', 'yes']:
                print("✅ 处理完成！备份文件已保留以防需要回滚。")
                break
            elif choice in ['r', 'rollback']:
                print("🔄 开始回滚更改...")
                localizer.rollback()
                print("✅ 回滚完成！")
                break
            elif choice in ['n', 'no']:
                print("❌ 如需回滚，请重新运行并选择 'r'")
                break
            else:
                print("请输入 y/n/r")
                
    except KeyboardInterrupt:
        print("\n❌ 用户中断处理")
        choice = input("是否要回滚已做的更改？(y/n): ").lower().strip()
        if choice in ['y', 'yes']:
            localizer.rollback()
            print("✅ 回滚完成！")
    except Exception as e:
        print(f"❌ 处理出错: {e}")
        choice = input("是否要回滚已做的更改？(y/n): ").lower().strip()
        if choice in ['y', 'yes']:
            localizer.rollback()
            print("✅ 回滚完成！")

if __name__ == "__main__":
    main()
