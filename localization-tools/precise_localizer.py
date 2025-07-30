#!/usr/bin/env python3
"""
精确本地化工具 - 专门处理UI字符串的本地化
只替换UI相关的硬编码字符串，避免影响代码逻辑
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple, Set
import argparse

class PreciseLocalizer:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.localizable_strings = {}
        self.ui_patterns = [
            # SwiftUI Text组件
            r'Text\s*\(\s*"([^"]+)"\s*\)',
            # 按钮标题
            r'Button\s*\(\s*"([^"]+)"\s*[,\)]',
            # Label组件
            r'Label\s*\(\s*"([^"]+)"\s*[,\)]',
            # NavigationTitle
            r'\.navigationTitle\s*\(\s*"([^"]+)"\s*\)',
            # Alert和Sheet的标题
            r'\.alert\s*\(\s*"([^"]+)"\s*[,\)]',
            r'\.sheet\s*\([^}]*title:\s*"([^"]+)"',
            # Menu项目
            r'Menu\s*\(\s*"([^"]+)"\s*[,\)]',
            # Picker选项
            r'Picker\s*\(\s*"([^"]+)"\s*[,\)]',
            # Toggle标题
            r'Toggle\s*\(\s*"([^"]+)"\s*[,\)]',
            # Section标题
            r'Section\s*\(\s*"([^"]+)"\s*[,\)]',
            # Form字段
            r'TextField\s*\(\s*"([^"]+)"\s*[,\)]',
            # HStack/VStack中的直接文本
            r'HStack\s*{[^}]*Text\s*\(\s*"([^"]+)"\s*\)',
            r'VStack\s*{[^}]*Text\s*\(\s*"([^"]+)"\s*\)',
            # 更多UI组件模式
            r'title:\s*"([^"]+)"',  # 通用title参数
            r'placeholder:\s*"([^"]+)"',  # placeholder参数
            r'message:\s*"([^"]+)"',  # message参数
            r'\.tag\s*\(\s*"([^"]+)"\s*\)',  # tag参数
            r'\.accessibility\w*\s*\(\s*"([^"]+)"\s*\)',  # accessibility相关
            r'\.help\s*\(\s*"([^"]+)"\s*\)',  # help文本
            r'\.confirmationDialog\s*\(\s*"([^"]+)"\s*',  # 确认对话框
            r'\.toolbar\s*{[^}]*Text\s*\(\s*"([^"]+)"\s*\)',  # toolbar中的文本
            # 字符串插值和格式化
            r'"([^"]*[A-Za-z]{3,}[^"]*)"(?=\s*\+|\s*,|\s*\))',  # 独立字符串
            # 更复杂的UI模式
            r'HStack\s*\([^)]*\)\s*{[^}]*"([^"]+)"',  # HStack中的字符串
            r'VStack\s*\([^)]*\)\s*{[^}]*"([^"]+)"',  # VStack中的字符串
            r'Group\s*{[^}]*"([^"]+)"',  # Group中的字符串
            # 条件语句中的字符串
            r'\?\s*"([^"]+)"\s*:',  # 三元运算符中的字符串
            r':\s*"([^"]+)"',  # 三元运算符的另一部分
        ]
        
        # 需要避免的模式（代码逻辑相关）
        self.avoid_patterns = [
            r'UserDefaults\.standard\.',
            r'\.forKey\s*\(',
            r'NSPasteboard\.',
            r'Bundle\.main\.',
            r'FileManager\.',
            r'URL\(',
            r'\.plist',
            r'\.framework',
            r'\.bundle',
            r'\.xcassets',
            r'case\s+\w+\s*=',
            r'enum\s+\w+.*{',
            r'struct\s+\w+.*{',
            r'class\s+\w+.*{',
            r'func\s+\w+',
            r'var\s+\w+',
            r'let\s+\w+',
            r'import\s+',
            r'@\w+',
            r'#\w+',
            r'//.*',
            r'/\*.*\*/',
        ]

    def load_localizable_strings(self, strings_file: str) -> Dict[str, str]:
        """加载Localizable.strings文件"""
        strings_path = self.project_root / strings_file
        if not strings_path.exists():
            print(f"❌ 找不到本地化文件: {strings_path}")
            return {}
        
        strings_dict = {}
        try:
            with open(strings_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # 解析.strings文件格式: "key" = "value";
            pattern = r'"([^"]+)"\s*=\s*"([^"]+)"\s*;'
            matches = re.findall(pattern, content)
            
            for key, value in matches:
                strings_dict[key] = value
                
            print(f"✅ 加载了 {len(strings_dict)} 个本地化键值对")
            return strings_dict
            
        except Exception as e:
            print(f"❌ 解析本地化文件失败: {e}")
            return {}

    def is_code_logic(self, line: str, text: str) -> bool:
        """判断是否为代码逻辑相关的字符串"""
        # 检查行内容是否包含避免模式
        for pattern in self.avoid_patterns:
            if re.search(pattern, line):
                return True
        
        # 检查字符串本身是否为技术性内容
        technical_indicators = [
            r'^[a-z]+\.[a-z]+',  # 类似 com.example
            r'^\w+\.\w+$',       # 键值对格式
            r'^[A-Z_]+$',        # 常量格式
            r'^\w+://',          # URL scheme
            r'\.(png|jpg|mp3|wav|plist)$',  # 文件扩展名
        ]
        
        for pattern in technical_indicators:
            if re.match(pattern, text):
                return True
                
        return False

    def find_ui_strings(self, file_path: Path) -> List[Tuple[int, str, str]]:
        """在Swift文件中查找UI相关的硬编码字符串"""
        if not file_path.exists() or file_path.suffix != '.swift':
            return []
        
        results = []
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for line_num, line in enumerate(lines, 1):
                # 跳过注释行
                if re.match(r'^\s*(//|/\*|\*)', line.strip()):
                    continue
                
                # 查找UI模式
                for pattern in self.ui_patterns:
                    matches = re.finditer(pattern, line)
                    for match in matches:
                        text = match.group(1)
                        
                        # 跳过空字符串和技术性字符串
                        if not text.strip() or self.is_code_logic(line, text):
                            continue
                        
                        # 检查是否已经本地化
                        if 'NSLocalizedString' in line:
                            continue
                            
                        # 检查是否在本地化字典中有对应的键
                        if text in self.localizable_strings:
                            results.append((line_num, line.strip(), text))
                            
        except Exception as e:
            print(f"❌ 读取文件失败 {file_path}: {e}")
            
        return results

    def generate_replacement(self, original_line: str, text: str) -> str:
        """生成替换后的代码行"""
        # 替换Text组件
        if f'Text("{text}")' in original_line:
            return original_line.replace(
                f'Text("{text}")',
                f'Text(NSLocalizedString("{text}", comment: "{text}"))'
            )
        
        # 替换Button
        if f'Button("{text}"' in original_line:
            return original_line.replace(
                f'Button("{text}"',
                f'Button(NSLocalizedString("{text}", comment: "{text}")'
            )
        
        # 其他组件的通用替换
        return original_line.replace(
            f'"{text}"',
            f'NSLocalizedString("{text}", comment: "{text}")'
        )

    def scan_project(self) -> Dict[str, List[Tuple[int, str, str]]]:
        """扫描项目中的所有Swift文件"""
        results = {}
        swift_files = list(self.project_root.rglob("*.swift"))
        
        # 排除一些不需要本地化的文件
        excluded_patterns = [
            r'.*Tests?/',
            r'.*/Build/',
            r'.*/DerivedData/',
            r'.*\.build/',
            r'.*Package\.swift$',
        ]
        
        for file_path in swift_files:
            # 检查是否应该排除
            relative_path = str(file_path.relative_to(self.project_root))
            if any(re.match(pattern, relative_path) for pattern in excluded_patterns):
                continue
            
            ui_strings = self.find_ui_strings(file_path)
            if ui_strings:
                results[relative_path] = ui_strings
                
        return results

    def create_replacement_plan(self, scan_results: Dict[str, List[Tuple[int, str, str]]]) -> Dict[str, List[Dict]]:
        """创建替换计划"""
        plan = {}
        
        for file_path, findings in scan_results.items():
            file_plan = []
            for line_num, original_line, text in findings:
                new_line = self.generate_replacement(original_line, text)
                file_plan.append({
                    'line_number': line_num,
                    'original': original_line,
                    'replacement': new_line,
                    'text': text,
                    'chinese_translation': self.localizable_strings.get(text, "未找到翻译")
                })
            
            if file_plan:
                plan[file_path] = file_plan
                
        return plan

    def apply_replacements(self, plan: Dict[str, List[Dict]], dry_run: bool = True):
        """应用替换（支持预览模式）"""
        if dry_run:
            print("\n🔍 替换预览（不会实际修改文件）:")
            print("=" * 60)
        else:
            print("\n✏️ 开始应用替换:")
            print("=" * 60)
        
        total_files = len(plan)
        total_replacements = sum(len(file_plan) for file_plan in plan.values())
        
        for file_path, file_plan in plan.items():
            print(f"\n📁 {file_path} ({len(file_plan)} 个替换)")
            
            if not dry_run:
                # 实际修改文件
                full_path = self.project_root / file_path
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                    
                    # 从后往前替换，避免行号变化影响
                    for replacement in sorted(file_plan, key=lambda x: x['line_number'], reverse=True):
                        line_idx = replacement['line_number'] - 1
                        if line_idx < len(lines):
                            lines[line_idx] = replacement['replacement'] + '\n'
                    
                    with open(full_path, 'w', encoding='utf-8') as f:
                        f.writelines(lines)
                    
                    print(f"  ✅ 已修改文件")
                    
                except Exception as e:
                    print(f"  ❌ 修改文件失败: {e}")
            
            # 显示替换详情
            for replacement in file_plan:
                print(f"  📍 第{replacement['line_number']}行:")
                print(f"    原文: {replacement['text']}")
                print(f"    中文: {replacement['chinese_translation']}")
                if dry_run:
                    print(f"    原代码: {replacement['original']}")
                    print(f"    新代码: {replacement['replacement']}")
                print()
        
        print(f"\n📊 总结: {total_files} 个文件, {total_replacements} 个替换")

def main():
    parser = argparse.ArgumentParser(description='精确本地化工具')
    parser.add_argument('--project-root', default='/Users/maoking/Downloads/VoiceInk-CN', 
                       help='项目根目录')
    parser.add_argument('--strings-file', default='VoiceInk/zh-Hans.lproj/Localizable.strings',
                       help='本地化字符串文件路径')
    parser.add_argument('--apply', action='store_true', help='实际应用替换（默认为预览模式）')
    parser.add_argument('--files', nargs='*', help='指定要处理的文件（相对路径）')
    
    args = parser.parse_args()
    
    localizer = PreciseLocalizer(args.project_root)
    
    # 加载本地化字符串
    localizer.localizable_strings = localizer.load_localizable_strings(args.strings_file)
    if not localizer.localizable_strings:
        return
    
    print(f"\n🚀 精确本地化工具")
    print(f"📁 项目根目录: {args.project_root}")
    print(f"📄 本地化文件: {args.strings_file}")
    print(f"🔧 模式: {'应用替换' if args.apply else '预览模式'}")
    
    # 扫描项目
    if args.files:
        # 处理指定文件
        scan_results = {}
        for file_path in args.files:
            full_path = Path(args.project_root) / file_path
            ui_strings = localizer.find_ui_strings(full_path)
            if ui_strings:
                scan_results[file_path] = ui_strings
    else:
        # 扫描整个项目
        scan_results = localizer.scan_project()
    
    if not scan_results:
        print("\n✅ 未找到需要本地化的硬编码字符串")
        return
    
    # 创建替换计划
    plan = localizer.create_replacement_plan(scan_results)
    
    # 应用或预览替换
    localizer.apply_replacements(plan, dry_run=not args.apply)
    
    if not args.apply:
        print(f"\n💡 要实际应用这些替换，请运行: python3 {__file__} --apply")

if __name__ == '__main__':
    main()
