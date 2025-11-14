#!/usr/bin/env python3
"""
Unified Localizer
Provides two modes under one entrypoint:
- smart: config-driven safe localization with backups
- precise: pattern-based scan and optional apply
"""

import os
import re
import sys
import glob
import yaml
import shutil
import logging
import argparse
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Set, Tuple


class SmartLocalizer:
    """Smart localizer (merged from smart_localize.py)"""

    def __init__(self, config_path: str = "localization-tools/config.yaml"):
        self.config = self._load_config(config_path)
        self._setup_logging()
        self.processed_files: List[str] = []
        self.backup_files: List[str] = []

    def _load_config(self, config_path: str) -> dict:
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ 无法加载配置文件 {config_path}: {e}")
            return {}

    def _setup_logging(self):
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
        target_files: List[str] = []
        include_paths = self.config.get('include_paths', [])
        exclude_files = self.config.get('exclude_files', [])

        for pattern in include_paths:
            files = glob.glob(pattern, recursive=True)
            target_files.extend(files)

        filtered_files: List[str] = []
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
        exclude_patterns = self.config.get('exclude_string_patterns', [])
        for pattern in exclude_patterns:
            if re.search(pattern, string):
                return False

        exclude_contexts = self.config.get('exclude_contexts', [])
        for context_pattern in exclude_contexts:
            if re.search(context_pattern, context):
                return False

        if len(string) < 3:
            return False
        if not re.search(r'[a-zA-Z]', string):
            return False
        if re.match(r'^[0-9\s\-_.,:;!?]+$', string):
            return False
        if 'NSLocalizedString' in context:
            return False
        return True

    def extract_localizable_strings(self, file_path: str) -> List[Tuple[str, str, int]]:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            localizable_strings: List[Tuple[str, str, int]] = []
            lines = content.split('\n')
            pattern = r'"([A-Z][a-zA-Z\s:.,!?\'-]{3,})"'
            for line_num, line in enumerate(lines, 1):
                for match in re.finditer(pattern, line):
                    string = match.group(1)
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
        try:
            if not self.create_backup(file_path):
                return 0
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            original_content = content
            changes = 0

            common_localizations = self.config.get('common_localizations', {})
            for string, (key, comment) in common_localizations.items():
                replacement_pattern = f'(Button|Text|Label|Toggle|Menu)\\s*\\(\\s*"{re.escape(string)}"'
                if re.search(replacement_pattern, content, re.IGNORECASE):
                    new_content = re.sub(
                        f'"{re.escape(string)}"(?!\\s*,\\s*comment:)',
                        f'NSLocalizedString("{key}", comment: "{comment}")',
                        content
                    )
                    if new_content != content:
                        content = new_content
                        changes += 1

            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                self.processed_files.append(file_path)
                self.logger.info(f"✅ {file_path}: {changes} 处修改")
                return changes
            else:
                backup_path = f"{file_path}{self.config.get('output', {}).get('backup_suffix', '.backup')}"
                if os.path.exists(backup_path):
                    os.remove(backup_path)
                    if backup_path in self.backup_files:
                        self.backup_files.remove(backup_path)
                return 0
        except Exception as e:
            self.logger.error(f"处理文件失败 {file_path}: {e}")
            return 0

    def run(self) -> dict:
        start_time = datetime.now()
        self.logger.info("🚀 开始智能本地化处理")
        target_files = self.find_target_files()
        self.logger.info(f"📁 找到 {len(target_files)} 个目标文件")

        before_strings: Set[str] = set()
        for file_path in target_files:
            strings = self.extract_localizable_strings(file_path)
            before_strings.update([s[0] for s in strings])

        total_changes = 0
        processed_count = 0
        for file_path in target_files:
            changes = self.localize_file(file_path)
            if changes > 0:
                total_changes += changes
                processed_count += 1

        end_time = datetime.now()
        duration = end_time - start_time
        report = {
            'duration': duration.total_seconds(),
            'target_files': len(target_files),
            'processed_files': processed_count,
            'total_changes': total_changes,
            'backup_files': len(self.backup_files)
        }
        self.logger.info("🎉 本地化处理完成！")
        return report


class PreciseLocalizer:
    """Precise localizer (merged from precise_localizer.py)"""

    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.localizable_strings: Dict[str, str] = {}
        self.ui_patterns = [
            r'Text\s*\(\s*"([^"]+)"\s*\)',
            r'Button\s*\(\s*"([^"]+)"\s*[,\)]',
            r'Label\s*\(\s*"([^"]+)"\s*[,\)]',
            r'Toggle\s*\(\s*"([^"]+)"\s*[,\)]',
            r'Picker\s*\(\s*"([^"]+)"\s*[,\)]',
            r'TextField\s*\(\s*"([^"]+)"\s*[,\)]',
            r'SecureField\s*\(\s*"([^"]+)"\s*[,\)]',
            r'title:\s*"([^"]+)"',
            r'message:\s*"([^"]+)"',
            r'placeholder:\s*"([^"]+)"',
            r'\.help\s*\(\s*"([^"]+)"\s*\)',
            r'\.alert\s*\(\s*"([^"]+)"\s*[,\)]',
            r'return\s+"([^"]+)"',
            r'=\s*"([^"]+)"(?=\s*[;\n])',
            r'\?\s*"([^"]+)"\s*:',
            r':\s*"([^"]+)"(?=\s*[;\n\}])',
            r'case\s+"([^"]+)"',
            r'case\s+\.\w+:\s*return\s*"([^"]+)"',
            r'\[\s*"([^"]+)"\s*\]',
            r':\s*"([^"]+)"\s*[,\}]',
        ]
        self.avoid_patterns = [
            r'NSLocalizedString\s*\(',
            r'String\s*\(\s*localized:',
            r'UserDefaults\.standard\.',
            r'\.forKey\s*\(',
            r'NSPasteboard\.',
            r'Bundle\.main\.',
            r'FileManager\.',
            r'URL\(', r'\.plist', r'\.framework', r'\.bundle', r'\.xcassets',
            r'enum\s+\w+.*{', r'struct\s+\w+.*{', r'class\s+\w+.*{',
            r'func\s+\w+', r'var\s+\w+', r'let\s+\w+', r'import\s+', r'@\w+', r'#\w+',
            r'http[s]?://', r'[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            r'whisper.*?large.*?v3', r'gpt-[0-9]', r'claude-[0-9]', r'ggml-\w+',
        ]

    def load_localizable_strings(self, strings_file: str) -> Dict[str, str]:
        strings_path = self.project_root / strings_file
        if not strings_path.exists():
            return {}
        strings_dict: Dict[str, str] = {}
        try:
            with open(strings_path, 'r', encoding='utf-8') as f:
                content = f.read()
                pattern = r'"([^"]+)"\s*=\s*"([^"]+)";'
                for key, value in re.findall(pattern, content):
                    strings_dict[key] = value
        except Exception as e:
            print(f"❌ 读取文件失败 {strings_path}: {e}")
        return strings_dict

    def should_avoid_string(self, text: str, context: str) -> bool:
        for pattern in self.avoid_patterns:
            if re.search(pattern, context):
                return True
        if len(text.strip()) < 2:
            return True
        if re.match(r'^[0-9\s\-\+\.\,\%\$\#\@\!\?\&\*\(\)\[\]\{\}]*$', text):
            return True
        return False

    def find_hardcoded_strings(self, file_path: Path) -> List[Tuple[str, int, str, str]]:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ 读取文件失败 {file_path}: {e}")
            return []
        findings: List[Tuple[str, int, str, str]] = []
        lines = content.split('\n')
        for line_num, line in enumerate(lines, 1):
            for pattern in self.ui_patterns:
                for m in re.finditer(pattern, line):
                    text = m.group(1)
                    if self.should_avoid_string(text, line):
                        continue
                    if text in self.localizable_strings:
                        continue
                    findings.append((text, line_num, line.strip(), str(file_path)))
        return findings

    def scan_project(self) -> Dict[str, List[Tuple[str, int, str, str]]]:
        include_paths = ["VoiceInk/**/*.swift"]
        all_findings: Dict[str, List[Tuple[str, int, str, str]]] = {}
        for pattern in include_paths:
            for file_path in self.project_root.glob(pattern):
                if file_path.is_file():
                    findings = self.find_hardcoded_strings(file_path)
                    if findings:
                        rel_path = str(file_path.relative_to(self.project_root))
                        all_findings[rel_path] = findings
        return all_findings

    def apply_replacements(self, all_findings: Dict[str, List[Tuple[str, int, str, str]]]) -> int:
        total_replacements = 0
        for file_path, findings in all_findings.items():
            full_path = self.project_root / file_path
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                modified_content = content
                file_replacements = 0
                for text, line_num, line, _ in sorted(findings, key=lambda x: x[1], reverse=True):
                    old_pattern = f'"{text}"'
                    new_replacement = f'NSLocalizedString("{text}", comment: "{text}")'
                    if old_pattern in modified_content:
                        modified_content = modified_content.replace(old_pattern, new_replacement, 1)
                        file_replacements += 1
                if file_replacements > 0:
                    with open(full_path, 'w', encoding='utf-8') as f:
                        f.write(modified_content)
                    print(f"📁 {file_path} ({file_replacements} 个替换)")
                    total_replacements += file_replacements
            except Exception as e:
                print(f"❌ 处理文件失败 {file_path}: {e}")
        return total_replacements


def main():
    parser = argparse.ArgumentParser(description='Unified localizer')
    parser.add_argument('--mode', choices=['smart', 'precise'], required=True)
    parser.add_argument('--apply', action='store_true', help='apply replacements (precise mode)')
    parser.add_argument('--auto-confirm', action='store_true', help='non-interactive mode')
    args = parser.parse_args()

    if args.mode == 'smart':
        localizer = SmartLocalizer()
        try:
            report = localizer.run()
            if args.auto-confirm:
                print("\n✅ 自动确认模式：处理完成！")
            else:
                print("\n✅ 处理完成！备份文件已保留以防需要回滚。")
        except KeyboardInterrupt:
            print("\n❌ 用户中断处理")
            # rollback optional omitted for non-interactive consolidation
    else:
        pl = PreciseLocalizer('.')
        pl.localizable_strings = pl.load_localizable_strings('VoiceInk/zh-Hans.lproj/Localizable.strings')
        print("\n🚀 精确本地化工具")
        all_findings = pl.scan_project()
        if not all_findings:
            print("\n✅ 未找到需要本地化的硬编码字符串")
            return
        if args.apply:
            print("\n✏️ 开始应用替换:")
            total_replacements = pl.apply_replacements(all_findings)
            print(f"\n📊 总结: {len(all_findings)} 个文件, {total_replacements} 个替换")
        else:
            print("\n🔍 替换预览（不会实际修改文件）:")
            total_strings = 0
            for file_path, findings in all_findings.items():
                print(f"\n📁 {file_path} ({len(findings)} 个替换)")
                total_strings += len(findings)
                for text, line_num, line, _ in findings:
                    print(f"  📍 第{line_num}行: {text}")
            print(f"\n📊 总结: {len(all_findings)} 个文件, {total_strings} 个替换")
            if not args.auto-confirm:
                print("\n💡 要实际应用这些替换，请运行: python3 localization-tools/localizer.py --mode=precise --apply")


if __name__ == "__main__":
    main()
