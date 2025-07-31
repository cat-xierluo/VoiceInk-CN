#!/usr/bin/env python3
"""
VoiceInk 精确本地化工具 v2.1
专门检测和修复遗漏的硬编码英文字符串
"""

import os
import re
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Set

class PreciseLocalizer:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.localizable_strings = {}
        
        # 扩展的UI模式，特别针对状态信息、模型选择等
        self.ui_patterns = [
            # 基础UI组件
            r'Text\s*\(\s*"([^"]+)"\s*\)',
            r'Button\s*\(\s*"([^"]+)"\s*[,\)]',
            r'Label\s*\(\s*"([^"]+)"\s*[,\)]',
            r'Toggle\s*\(\s*"([^"]+)"\s*[,\)]',
            r'Picker\s*\(\s*"([^"]+)"\s*[,\)]',
            r'TextField\s*\(\s*"([^"]+)"\s*[,\)]',
            r'SecureField\s*\(\s*"([^"]+)"\s*[,\)]',
            
            # 状态和提示信息
            r'title:\s*"([^"]+)"',
            r'message:\s*"([^"]+)"',
            r'placeholder:\s*"([^"]+)"',
            r'\.help\s*\(\s*"([^"]+)"\s*\)',
            r'\.alert\s*\(\s*"([^"]+)"\s*[,\)]',
            
            # 函数返回值和变量赋值
            r'return\s+"([^"]+)"',
            r'=\s*"([^"]+)"(?=\s*[;\n])',
            
            # 条件语句中的字符串
            r'\?\s*"([^"]+)"\s*:',
            r':\s*"([^"]+)"(?=\s*[;\n\}])',
            
            # case语句和enum相关
            r'case\s+"([^"]+)"',
            r'case\s+\.\w+:\s*return\s*"([^"]+)"',
            
            # 数组和字典中的字符串
            r'\[\s*"([^"]+)"\s*\]',
            r':\s*"([^"]+)"\s*[,\}]',
            
            # 特定于您提到的问题
            # 状态信息
            r'"(Transcribing|No Audio Detected|Press ESC again to cancel recording)"',
            r'"(Recommended|Local|Cloud|Custom)"',
            r'"(Multilingual|Albanian|Armenian|Basque|Bosnian|Breton|Catalan|Estonian|Faroese|Galician|Georgian|Gujarati|Haitian Creole|Hausa|Hawaiian|Icelandic|Javanese|Kannada|Kazakh|Khmer|Lao|Latin|Latvian|Lingala|Lithuanian|Luxembourgish|Macedonian|Malagasy|Malayalam|Maltese|Maori|Marathi|Mongolian|Myanmar|Nepali|Norwegian Nynorsk|Occitan|Pashto|Persian|Punjabi|Sanskrit)"',
            r'"(Launch at login|Launch at Login|Thank you for supporting VoiceInk)"',
            r'"(Server URL|模型|刷新|已连接|Custom Provider Configuration|Requires OpenAI-compatible API endpoint)"',
            r'"(Word Replacements|Correct Spellings|Original Text|替换文本|验证并保存)"',
            
            # 提示词编辑器相关
            r'"(New Prompt|Edit Trigger Words|Ollama Configuration)"',
            
            # 模型和语言显示相关
            r'"(Current model:.*?)"',
            r'Current model:\s*([^"]+)"',
            
            # API配置占位符（长文本）
            r'"(API Endpoint URL.*?completions.*?)"',
            r'"(Model Name.*?gpt-4o-mini.*?)"',
            
            # 通用长占位符模式
            r'"([^"]*\(e\.g\.,[^"]+\))"',  # 包含 "(e.g.," 的占位符文本
            
            # 更多通用模式
            r'String\s*\(\s*"([^"]+)"\s*\)',
            r'NSString\s*\(\s*string:\s*"([^"]+)"\s*\)',
        ]
        
        # 需要避免的模式（代码逻辑相关）
        self.avoid_patterns = [
            r'NSLocalizedString\s*\(',  # 已经本地化的字符串
            r'String\s*\(\s*localized:',  # Swift 5.7+ 本地化语法
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
            r'\.rawValue',
            r'\.identifier',
            r'\.id\s*=',
            r'\.name\s*=',
            r'\.key\s*=',
            r'\.type\s*=',
            r'\.swift',
            r'\.m\b',
            r'\.h\b',
            r'\.json',
            r'\.xml',
            r'\.yaml',
            r'\.yml',
            r'http[s]?://',
            r'[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            r'Content-Type',
            r'Authorization',
            
            # 模型名称和专有名词相关的避免模式
            r'whisper.*?large.*?v3',  # 避免翻译whisper模型名称
            r'gpt-[0-9]',  # 避免翻译GPT模型名称
            r'claude-[0-9]',  # 避免翻译Claude模型名称
            r'ggml-\w+',  # 避免翻译ggml模型文件名
            r'Large v[0-9]|Base|Tiny|Medium|Small',  # 避免在非UI上下文中翻译模型大小
            r'\.displayName',  # 已经使用displayName的不需要再翻译
            r'enum.*rawValue',  # enum的rawValue不应被翻译
            r'application/',
            r'audio/',
            r'video/',
            r'image/',
            r'com\.',
            r'macOS',
            r'iOS',
            r'tvOS',
            r'watchOS',
            # 很短的字符串（通常是代码符号）
            r'^"[a-zA-Z0-9]{1,2}"$',
            # 纯数字或符号
            r'^"[0-9\s\-\+\.\,\%\$\#\@\!\?\&\*\(\)\[\]\{\}]*"$',
        ]

    def load_localizable_strings(self, strings_file: str) -> Dict[str, str]:
        """加载Localizable.strings文件"""
        strings_path = self.project_root / strings_file
        if not strings_path.exists():
            return {}
        
        strings_dict = {}
        try:
            with open(strings_path, 'r', encoding='utf-8') as f:
                content = f.read()
                # 匹配 "key" = "value"; 格式
                pattern = r'"([^"]+)"\s*=\s*"([^"]+)";'
                matches = re.findall(pattern, content)
                for key, value in matches:
                    strings_dict[key] = value
        except Exception as e:
            print(f"❌ 读取文件失败 {strings_path}: {e}")
        
        return strings_dict

    def should_avoid_string(self, text: str, context: str) -> bool:
        """检查是否应该避免本地化这个字符串"""
        # 检查避免模式
        for pattern in self.avoid_patterns:
            if re.search(pattern, context):
                return True
        
        # 过滤很短的字符串
        if len(text.strip()) < 2:
            return True
            
        # 过滤纯数字或符号
        if re.match(r'^[0-9\s\-\+\.\,\%\$\#\@\!\?\&\*\(\)\[\]\{\}]*$', text):
            return True
            
        return False

    def find_hardcoded_strings(self, file_path: Path) -> List[Tuple[str, int, str, str]]:
        """在文件中查找硬编码字符串"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ 读取文件失败 {file_path}: {e}")
            return []

        findings = []
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            for pattern in self.ui_patterns:
                matches = re.finditer(pattern, line)
                for match in matches:
                    text = match.group(1)
                    
                    # 跳过应该避免的字符串
                    if self.should_avoid_string(text, line):
                        continue
                    
                    # 跳过已经在本地化文件中的字符串
                    if text in self.localizable_strings:
                        continue
                    
                    findings.append((text, line_num, line.strip(), str(file_path)))
        
        return findings

    def scan_project(self) -> Dict[str, List[Tuple[str, int, str, str]]]:
        """扫描整个项目"""
        print("✅ 加载了", len(self.localizable_strings), "个本地化键值对")
        
        # 扫描包含路径
        include_paths = [
            "VoiceInk/**/*.swift"
        ]
        
        all_findings = {}
        
        for pattern in include_paths:
            for file_path in self.project_root.glob(pattern):
                if file_path.is_file():
                    findings = self.find_hardcoded_strings(file_path)
                    if findings:
                        rel_path = str(file_path.relative_to(self.project_root))
                        all_findings[rel_path] = findings
        
        return all_findings

    def apply_replacements(self, all_findings: Dict[str, List[Tuple[str, int, str, str]]]) -> int:
        """应用本地化替换"""
        total_replacements = 0
        
        for file_path, findings in all_findings.items():
            full_path = self.project_root / file_path
            
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                modified_content = content
                file_replacements = 0
                
                # 按行号倒序处理，避免位置偏移
                for text, line_num, line, _ in sorted(findings, key=lambda x: x[1], reverse=True):
                    # 构建本地化替换
                    old_pattern = f'"{text}"'
                    new_replacement = f'NSLocalizedString("{text}", comment: "{text}")'
                    
                    # 只替换第一个匹配项以避免重复替换
                    if old_pattern in modified_content:
                        modified_content = modified_content.replace(old_pattern, new_replacement, 1)
                        file_replacements += 1
                
                if file_replacements > 0:
                    with open(full_path, 'w', encoding='utf-8') as f:
                        f.write(modified_content)
                    
                    print(f"📁 {file_path} ({file_replacements} 个替换)")
                    print("  ✅ 已修改文件")
                    
                    for text, line_num, line, _ in findings:
                        print(f"  📍 第{line_num}行:")
                        print(f"    原文: {text}")
                    
                    total_replacements += file_replacements
                
            except Exception as e:
                print(f"❌ 处理文件失败 {file_path}: {e}")
        
        return total_replacements

def main():
    parser = argparse.ArgumentParser(description='VoiceInk 精确本地化工具')
    parser.add_argument('--apply', action='store_true', help='应用替换（默认为预览模式）')
    parser.add_argument('--auto-confirm', action='store_true', help='自动确认模式（与--apply一起使用）')
    args = parser.parse_args()
    
    # 如果使用了--auto-confirm，自动开启--apply
    if args.auto_confirm:
        args.apply = True

    localizer = PreciseLocalizer('.')
    
    # 加载现有本地化字符串
    localizer.localizable_strings = localizer.load_localizable_strings('VoiceInk/zh-Hans.lproj/Localizable.strings')
    
    print("\n🚀 精确本地化工具")
    print("📁 项目根目录:", localizer.project_root.absolute())
    print("📄 本地化文件: VoiceInk/zh-Hans.lproj/Localizable.strings")
    print("🔧 模式:", "自动确认应用替换" if args.auto_confirm else ("应用替换" if args.apply else "预览模式"))
    
    # 扫描项目
    all_findings = localizer.scan_project()
    
    if not all_findings:
        print("\n✅ 未找到需要本地化的硬编码字符串")
        return
    
    # 统计信息
    total_files = len(all_findings)
    total_strings = sum(len(findings) for findings in all_findings.values())
    
    if args.apply:
        print(f"\n✏️ 开始应用替换:")
        print("=" * 60)
        total_replacements = localizer.apply_replacements(all_findings)
        print(f"\n📊 总结: {total_files} 个文件, {total_replacements} 个替换")
    else:
        print(f"\n🔍 替换预览（不会实际修改文件）:")
        print("=" * 60)
        
        for file_path, findings in all_findings.items():
            print(f"\n📁 {file_path} ({len(findings)} 个替换)")
            for text, line_num, line, _ in findings:
                # 尝试从现有本地化文件中找到中文翻译
                chinese_text = localizer.localizable_strings.get(text, text)
                print(f"  📍 第{line_num}行:")
                print(f"    原文: {text}")
                print(f"    中文: {chinese_text}")
                print(f"    原代码: {line}")
                old_str = f'"{text}"'
                new_str = f'NSLocalizedString("{text}", comment: "{text}")'
                print(f"    新代码: {line.replace(old_str, new_str)}")
                print()
        
        print(f"\n📊 总结: {total_files} 个文件, {total_strings} 个替换")
        if not args.auto_confirm:
            print(f"\n💡 要实际应用这些替换，请运行: python3 {sys.argv[0]} --apply")
    
    # 自动确认模式的特殊处理
    if args.auto_confirm and args.apply:
        print("\n✅ 自动确认模式：处理完成！")

if __name__ == "__main__":
    main()
