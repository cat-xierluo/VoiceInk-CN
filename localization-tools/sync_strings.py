#!/usr/bin/env python3
"""
VoiceInk 本地化字符串同步脚本
用于在项目更新后同步新增的本地化键到.strings文件
"""

import re
import os
from datetime import datetime
from typing import Dict, Set, Tuple, List

class StringsSyncer:
    def __init__(self):
        self.en_file = "en.lproj/Localizable.strings"
        self.zh_file = "zh-Hans.lproj/Localizable.strings"
    
    def extract_used_keys(self) -> Set[str]:
        """提取代码中使用的所有NSLocalizedString键"""
        used_keys = set()
        
        # 遍历所有Swift文件
        for root, dirs, files in os.walk('VoiceInk'):
            for file in files:
                if file.endswith('.swift'):
                    file_path = os.path.join(root, file)
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                        
                        # 查找NSLocalizedString调用
                        pattern = r'NSLocalizedString\\("([^"]+)",\\s*comment:'
                        matches = re.findall(pattern, content)
                        used_keys.update(matches)
                        
                    except Exception as e:
                        print(f"读取文件出错 {file_path}: {e}")
        
        return used_keys
    
    def extract_existing_keys(self, file_path: str) -> Dict[str, str]:
        """提取现有.strings文件中的键值对"""
        keys = {}
        
        if not os.path.exists(file_path):
            print(f"⚠️  文件不存在: {file_path}")
            return keys
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 匹配键值对: "key" = "value";
            pattern = r'^"([^"]+)"\\s*=\\s*"([^"]*)";?\\s*$'
            for line in content.split('\\n'):
                line = line.strip()
                match = re.match(pattern, line)
                if match:
                    key, value = match.groups()
                    keys[key] = value
                    
        except Exception as e:
            print(f"读取本地化文件出错 {file_path}: {e}")
        
        return keys
    
    def generate_chinese_translation(self, english_key: str) -> str:
        """为英文键生成中文翻译（简单映射，实际使用时需要人工翻译）"""
        # 这里是一个基础的翻译映射，实际使用时应该通过翻译服务或人工翻译
        basic_translations = {
            # UI基础词汇
            "Save": "保存",
            "Cancel": "取消", 
            "Delete": "删除",
            "Edit": "编辑",
            "Add": "添加",
            "Done": "完成",
            "Close": "关闭",
            "Back": "返回",
            "Next": "下一步",
            "Continue": "继续",
            "Copy": "复制",
            "Paste": "粘贴",
            "Settings": "设置",
            
            # 状态
            "Active": "激活",
            "Inactive": "未激活",
            "Loading": "加载中",
            "Processing": "处理中",
            "Ready": "就绪",
            "Unknown": "未知",
            "None": "无",
            
            # VoiceInk特定
            "VoiceInk Pro": "VoiceInk Pro",
            "Transcription": "转录",
            "Recording": "录音",
            "Enhancement": "增强",
            "AI Models": "AI 模型",
            "Power Mode": "专业模式",
            "Dictionary": "词典",
            "History": "历史记录",
            "Audio Input": "音频输入",
            "Permissions": "权限",
            
            # 更多映射...
            "Start Recording": "开始录音",
            "Stop Recording": "停止录音",
            "Start Transcription": "开始转录",
            "Toggle Mini Recorder": "切换迷你录音器",
            "Configure Shortcut": "配置快捷键",
            "Manage Models": "管理模型",
            "Manage AI Providers": "管理AI提供商",
            "App Permissions": "应用权限",
            "Keyboard Shortcut": "键盘快捷键",
            "Accessibility Access": "辅助功能访问",
            "Microphone Access": "麦克风访问",
            "Screen Recording Access": "屏幕录制访问",
        }
        
        # 优先使用预定义翻译
        if english_key in basic_translations:
            return basic_translations[english_key]
        
        # 对于未知的键，返回标记需要翻译的版本
        return f"[需要翻译] {english_key}"
    
    def backup_files(self):
        """备份现有的本地化文件"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        for file_path in [self.en_file, self.zh_file]:
            if os.path.exists(file_path):
                backup_path = f"{file_path}.backup_{timestamp}"
                try:
                    import shutil
                    shutil.copy2(file_path, backup_path)
                    print(f"✅ 备份创建: {backup_path}")
                except Exception as e:
                    print(f"❌ 备份失败 {file_path}: {e}")
    
    def update_strings_file(self, file_path: str, existing_keys: Dict[str, str], 
                           new_keys: Set[str], is_chinese: bool = False) -> int:
        """更新.strings文件"""
        added_count = 0
        
        try:
            # 读取现有内容
            if os.path.exists(file_path):
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            else:
                content = ""
            
            # 添加新键
            new_entries = []
            for key in sorted(new_keys):
                if key not in existing_keys:
                    if is_chinese:
                        value = self.generate_chinese_translation(key)
                    else:
                        value = key  # 英文文件中键和值相同
                    
                    new_entries.append(f'"{key}" = "{value}";')
                    added_count += 1
            
            if new_entries:
                # 添加新键到文件末尾
                if content and not content.endswith('\\n'):
                    content += '\\n'
                
                content += f'\\n/* 新增的本地化键 - {datetime.now().strftime("%Y-%m-%d")} */\\n'
                content += '\\n'.join(new_entries) + '\\n'
                
                # 写回文件
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
        
        except Exception as e:
            print(f"❌ 更新文件失败 {file_path}: {e}")
        
        return added_count
    
    def validate_strings_files(self) -> Tuple[bool, List[str]]:
        """验证.strings文件的格式和一致性"""
        errors = []
        
        # 检查文件是否存在
        if not os.path.exists(self.en_file):
            errors.append(f"英文本地化文件不存在: {self.en_file}")
        if not os.path.exists(self.zh_file):
            errors.append(f"中文本地化文件不存在: {self.zh_file}")
        
        if errors:
            return False, errors
        
        # 提取键
        en_keys = set(self.extract_existing_keys(self.en_file).keys())
        zh_keys = set(self.extract_existing_keys(self.zh_file).keys())
        
        # 检查键的一致性
        missing_in_zh = en_keys - zh_keys
        missing_in_en = zh_keys - en_keys
        
        if missing_in_zh:
            errors.append(f"中文文件中缺失 {len(missing_in_zh)} 个键: {list(missing_in_zh)[:5]}...")
        
        if missing_in_en:
            errors.append(f"英文文件中缺失 {len(missing_in_en)} 个键: {list(missing_in_en)[:5]}...")
        
        return len(errors) == 0, errors
    
    def sync(self) -> Dict[str, int]:
        """执行同步操作"""
        print("🔄 开始同步本地化字符串...")
        
        # 1. 提取代码中使用的键
        print("📝 扫描代码中的本地化键...")
        used_keys = self.extract_used_keys()
        print(f"   发现 {len(used_keys)} 个使用中的本地化键")
        
        # 2. 提取现有文件中的键
        print("📋 检查现有本地化文件...")
        en_keys = self.extract_existing_keys(self.en_file)
        zh_keys = self.extract_existing_keys(self.zh_file)
        print(f"   英文文件: {len(en_keys)} 个键")
        print(f"   中文文件: {len(zh_keys)} 个键")
        
        # 3. 找出需要添加的新键
        new_keys = used_keys - set(en_keys.keys())
        print(f"📈 发现 {len(new_keys)} 个新键需要添加")
        
        if not new_keys:
            print("✅ 无需同步，所有键都已存在")
            return {"added_en": 0, "added_zh": 0}
        
        # 4. 创建备份
        print("💾 创建备份文件...")
        self.backup_files()
        
        # 5. 更新文件
        print("📝 更新本地化文件...")
        added_en = self.update_strings_file(self.en_file, en_keys, new_keys, is_chinese=False)
        added_zh = self.update_strings_file(self.zh_file, zh_keys, new_keys, is_chinese=True)
        
        print(f"✅ 同步完成!")
        print(f"   英文文件新增: {added_en} 个键")
        print(f"   中文文件新增: {added_zh} 个键")
        
        # 6. 验证结果
        print("🔍 验证同步结果...")
        is_valid, errors = self.validate_strings_files()
        if is_valid:
            print("✅ 验证通过，文件格式正确且键同步")
        else:
            print("⚠️  验证发现问题:")
            for error in errors:
                print(f"   - {error}")
        
        # 7. 检查需要人工翻译的项目
        if added_zh > 0:
            print("\\n⚠️  注意: 以下新增的中文翻译可能需要人工校对:")
            zh_keys_updated = self.extract_existing_keys(self.zh_file)
            for key in sorted(new_keys):
                if key in zh_keys_updated and "[需要翻译]" in zh_keys_updated[key]:
                    print(f"   - \"{key}\" = \"{zh_keys_updated[key]}\"")
        
        return {"added_en": added_en, "added_zh": added_zh, "new_keys": list(new_keys)}

def main():
    """主函数"""
    print("🚀 VoiceInk 本地化字符串同步工具")
    print("=" * 50)
    
    syncer = StringsSyncer()
    
    try:
        result = syncer.sync()
        
        if result["added_en"] > 0 or result["added_zh"] > 0:
            print(f"\\n🎉 同步完成！新增了 {result['added_en']} 个英文键和 {result['added_zh']} 个中文键")
            if "new_keys" in result:
                print("\\n新增的键:")
                for key in result["new_keys"][:10]:  # 只显示前10个
                    print(f"  - {key}")
                if len(result["new_keys"]) > 10:
                    print(f"  ... 还有 {len(result['new_keys']) - 10} 个")
        else:
            print("\\n✅ 所有本地化键都已同步，无需更新")
            
    except Exception as e:
        print(f"❌ 同步过程出错: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
