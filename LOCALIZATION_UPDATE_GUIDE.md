# VoiceInk 本地化更新指南

## 概述

本文档描述了当 VoiceInk 原项目更新时，如何高效地同步和更新中文本地化的完整流程。该流程旨在最小化手动工作，确保翻译质量，并保持与上游项目的同步。

## 前置准备

### 必需工具
- **Xcode** - 用于构建和测试
- **终端工具** - 用于脚本执行
- **文本编辑器** - VS Code 或类似工具，支持多文件搜索
- **Git** - 版本控制
- **Python 3.x** - 用于自动化脚本（可选但推荐）

### 推荐工具
- **i18n-tools** - 国际化工具包
- **diff 工具** - 文件对比工具
- **翻译记忆库** - 如 SDL Trados 或 OmegaT

## 更新检测流程

### 1. 版本差异检测
```bash
# 1. 获取最新上游代码
git fetch upstream
git checkout main
git merge upstream/main

# 2. 检测新增或修改的 Swift 文件
git diff HEAD~1 HEAD --name-only | grep "\.swift$"

# 3. 检测新增或修改的字符串文件
git diff HEAD~1 HEAD --name-only | grep "Localizable.strings$"
```

### 2. 字符串变更分析
```bash
# 使用脚本检测新增/删除的字符串
python3 scripts/analyze_localization_changes.py
```

## 自动化更新步骤

### 阶段一：变更识别

#### 1.1 扫描新增硬编码字符串
```bash
# 扫描新增的 NSLocalizedString 调用
grep -r "NSLocalizedString" --include="*.swift" . > new_strings.txt

# 扫描新增的 SwiftUI 本地化文本
grep -r "\.localizedStringKey" --include="*.swift" . >> new_strings.txt
```

#### 1.2 识别未本地化文本
```bash
# 使用正则表达式查找潜在的硬编码英文文本
find . -name "*.swift" -exec grep -l '"[A-Z][a-z].*"' {} \; > potential_hardcoded.txt
```

#### 1.3 对比英文和中文文件
```bash
# 提取英文键值对
grep '^".*"' en.lproj/Localizable.strings | sort > en_keys.txt

# 提取中文键值对  
grep '^".*"' zh-Hans.lproj/Localizable.strings | sort > zh_keys.txt

# 找出缺失的翻译
comm -23 en_keys.txt zh_keys.txt > missing_translations.txt
```

### 阶段二：翻译同步

#### 2.1 创建翻译任务清单
基于缺失翻译生成任务清单：

```markdown
## 待翻译内容 - 版本 X.Y.Z

### 新增字符串
- [ ] "New Feature Title" = "新功能标题"
- [ ] "Enable advanced mode" = "启用高级模式"

### 修改字符串
- [ ] "Old text" -> "Updated text" = "更新后的文本"

### 上下文信息
- 文件位置：Views/SettingsView.swift:45
- 使用场景：设置页面的开关标签
- 字符限制：20字符以内
```

#### 2.2 批量翻译处理
使用翻译记忆库优先处理：

1. **精确匹配** - 直接复用现有翻译
2. **模糊匹配** - 人工确认后使用
3. **新内容** - 专业翻译或机器翻译+人工校对

#### 2.3 自动化翻译脚本
```python
# scripts/auto_translate.py
import json
import requests

def batch_translate(missing_keys, source_lang="en", target_lang="zh"):
    """批量翻译缺失的字符串"""
    translations = {}
    for key in missing_keys:
        # 调用翻译API或本地翻译记忆库
        translation = translate_text(key, source_lang, target_lang)
        translations[key] = translation
    return translations
```

### 阶段三：质量验证

#### 3.1 格式验证
```bash
# 验证 .strings 文件格式
plutil -lint zh-Hans.lproj/Localizable.strings

# 检查重复的键
duplicate_keys=$(grep -o '^"[^"]*"' zh-Hans.lproj/Localizable.strings | sort | uniq -d)
```

#### 3.2 完整性检查
```bash
# 确保所有英文键都有对应中文翻译
python3 scripts/validate_translations.py --check-completeness

# 检查占位符一致性
python3 scripts/validate_placeholders.py
```

#### 3.3 上下文验证
```bash
# 检查字符串长度是否适合UI
python3 scripts/check_string_lengths.py --max-length 50

# 验证特殊字符和转义序列
python3 scripts/validate_escapes.py
```

## 手动更新流程

### 步骤1：环境准备
```bash
# 创建更新分支
git checkout -b update-localization-$(date +%Y%m%d)

# 备份现有翻译
cp zh-Hans.lproj/Localizable.strings zh-Hans.lproj/Localizable.strings.backup
```

### 步骤2：变更分析
1. **查看提交历史** - 了解最近的代码变更
2. **运行差异分析** - 识别新增/修改的字符串
3. **标记待翻译项** - 创建任务清单

### 步骤3：翻译执行
1. **优先处理** - 用户可见的核心功能字符串
2. **分批处理** - 按模块或功能分批翻译
3. **上下文确认** - 在应用中实际查看字符串使用场景

### 步骤4：测试验证
1. **构建测试** - 确保项目能正常编译
2. **界面测试** - 检查中文显示是否正常
3. **功能测试** - 验证所有功能在中文环境下工作

## 持续集成方案

### GitHub Actions 工作流
```yaml
# .github/workflows/localization-check.yml
name: Localization Check

on:
  pull_request:
    paths:
      - '**/*.swift'
      - '**/Localizable.strings'

jobs:
  check-localization:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check for missing translations
        run: |
          python3 scripts/check_missing_translations.py
      - name: Validate strings format
        run: |
          find . -name "*.strings" -exec plutil -lint {} \;
```

### 自动化脚本集合

#### 1. 更新检测脚本
```bash
#!/bin/bash
# scripts/detect_changes.sh

echo "=== 检测本地化变更 ==="

# 获取变更文件
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

# 检查Swift文件变更
if echo "$CHANGED_FILES" | grep -q "\.swift$"; then
    echo "检测到 Swift 文件变更，需要检查新增字符串"
    python3 scripts/scan_new_strings.py
fi

# 检查英文字符串文件变更
if echo "$CHANGED_FILES" | grep -q "en.lproj/Localizable.strings"; then
    echo "检测到英文字符串文件变更，需要同步翻译"
    python3 scripts/sync_translations.py
fi
```

#### 2. 翻译同步脚本
```bash
#!/bin/bash
# scripts/sync_translations.sh

echo "=== 同步翻译 ==="

# 提取新增键值
NEW_KEYS=$(python3 scripts/extract_new_keys.py)

if [ -n "$NEW_KEYS" ]; then
    echo "发现新增字符串，需要翻译:"
    echo "$NEW_KEYS"
    
    # 生成翻译任务文件
    python3 scripts/generate_translation_tasks.py "$NEW_KEYS"
    
    echo "翻译任务已生成: translation_tasks.md"
else
    echo "未发现新增字符串"
fi
```

## 最佳实践

### 1. 翻译规范
- **保持一致性** - 相同概念的翻译保持一致
- **简洁明了** - 避免过长的翻译影响UI布局
- **用户友好** - 使用用户熟悉的术语
- **上下文敏感** - 根据具体使用场景调整翻译

### 2. 版本管理
- **分支策略** - 为每次本地化更新创建独立分支
- **提交信息** - 使用清晰的提交信息，如 "Add Chinese translations for v2.1.0"
- **标签管理** - 为重要版本创建标签

### 3. 协作流程
- **任务分配** - 使用GitHub Issues跟踪翻译任务
- **审查机制** - 实施翻译质量审查流程
- **反馈收集** - 建立用户反馈渠道收集翻译问题

## 常见问题解决

### 问题1：字符串长度超限
**症状**：翻译文本过长导致UI显示异常
**解决方案**：
1. 使用缩写或简化表达
2. 调整UI布局适应文本
3. 使用多行文本显示

### 问题2：占位符不匹配
**症状**：运行时崩溃或显示异常
**解决方案**：
1. 检查占位符数量和类型
2. 使用验证脚本检测
3. 参考英文原文格式

### 问题3：编码问题
**症状**：中文字符显示为乱码
**解决方案**：
1. 确保文件使用UTF-8编码
2. 检查特殊字符转义
3. 验证文件BOM头

## 更新检查清单

### 每次更新前
- [ ] 创建新的工作分支
- [ ] 备份现有翻译文件
- [ ] 运行变更检测脚本
- [ ] 生成翻译任务清单

### 翻译过程中
- [ ] 按优先级分批处理
- [ ] 保持术语一致性
- [ ] 验证字符串格式
- [ ] 检查上下文适用性

### 完成后
- [ ] 运行完整验证套件
- [ ] 进行功能测试
- [ ] 更新版本号和变更日志
- [ ] 创建合并请求

## 自动化本地化工具包 🛠️

为了简化后续的本地化更新流程，我们开发了一套智能化的本地化工具包，位于 `localization-tools/` 目录中。

### 工具包组成

```
localization-tools/
├── README.md              # 详细使用说明
├── config.yaml           # 智能配置文件
├── localize.py           # 主控脚本
├── localize.sh           # 快捷启动脚本
├── smart_localize.py     # 智能本地化处理
├── sync_strings.py       # 字符串同步工具
├── setup.py              # 安装配置脚本
└── logs/                 # 处理日志目录
```

### 快速使用

#### 1. 初始化工具包
```bash
# 安装依赖和初始化
python3 localization-tools/setup.py

# 或使用快捷脚本
./localization-tools/localize.sh setup
```

#### 2. 项目更新后的本地化流程
```bash
# 方法一：执行完整工作流程（推荐）
./localization-tools/localize.sh full

# 方法二：分步执行
./localization-tools/localize.sh status    # 检查状态
./localization-tools/localize.sh smart     # 智能本地化
./localization-tools/localize.sh sync      # 同步字符串
./localization-tools/localize.sh cleanup   # 清理备份
```

### 工具优势

#### 🎯 智能识别
- **精确筛选**: 只处理用户界面相关的文件
- **上下文感知**: 区分UI文本和代码逻辑标识符
- **避免过度替换**: 防止破坏导航参数等代码逻辑

#### 🛡️ 安全保护
- **自动备份**: 处理前自动创建备份文件
- **一键回滚**: 支持快速撤销所有更改
- **验证检查**: 确保本地化文件格式正确

#### ⚡ 高效批量
- **批量处理**: 一次性处理多个文件
- **配置化**: 通过配置文件控制处理范围
- **日志记录**: 详细记录所有处理过程

### 配置说明

编辑 `localization-tools/config.yaml` 来定制处理规则：

```yaml
# 需要处理的文件路径
include_paths:
  - "VoiceInk/Views/**/*.swift"

# 需要排除的上下文（避免误处理）
exclude_contexts:
  - "openMainWindowAndNavigate\\(to:"  # 导航标识符
  - "forKey:"                          # 数据存储键

# 常用字符串映射
common_localizations:
  "Settings": ["Settings", "Settings"]
```

### 使用场景

#### 🔄 项目更新时
当VoiceInk有新版本更新时：
1. 拉取最新代码
2. 运行 `./localization-tools/localize.sh full`
3. 检查处理结果和日志
4. 人工校对新增的翻译

#### 🆕 新功能开发时
开发新功能后：
1. 运行 `./localization-tools/localize.sh smart`
2. 运行 `./localization-tools/localize.sh sync`
3. 校对新增的本地化内容

#### 🔍 问题排查时
遇到本地化问题时：
1. 运行 `./localization-tools/localize.sh status`
2. 查看 `localization-tools/logs/localization.log`
3. 根据日志定位和解决问题

### 最佳实践

#### ✅ 推荐做法
- 每次项目更新后运行完整流程
- 保留备份文件直到确认无问题
- 定期校对自动生成的翻译
- 及时更新配置文件以适应项目变化

#### ❌ 避免做法
- 不要手动修改工具生成的NSLocalizedString格式
- 不要删除代码逻辑相关的标识符本地化
- 不要跳过验证步骤直接使用结果

## 附录

### 有用命令速查
```bash
# 本地化工具包命令
./localization-tools/localize.sh status      # 检查状态
./localization-tools/localize.sh full        # 完整流程
./localization-tools/localize.sh cleanup     # 清理备份

# 传统手动命令
plutil -lint zh-Hans.lproj/Localizable.strings
grep -o '^"[^"]*"' zh-Hans.lproj/Localizable.strings | sort | uniq -d
wc -l en.lproj/Localizable.strings zh-Hans.lproj/Localizable.strings
grep -n "search_term" zh-Hans.lproj/Localizable.strings
```

### 资源链接
- [Apple Localization Guide](https://developer.apple.com/documentation/xcode/localization)
- [Swift String Localization](https://developer.apple.com/documentation/swiftui/localizedstringkey)
- [iOS Localization Best Practices](https://developer.apple.com/videos/play/wwdc2021/10220/)
- [工具包详细文档](localization-tools/README.md)

---

*最后更新：2024年*
*工具包版本：2.0*
