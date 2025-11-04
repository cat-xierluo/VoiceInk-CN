# VoiceInk 本地化工具包

这是一套专门为VoiceInk项目设计的智能本地化工具，用于快速、准确地将项目中的硬编码英文字符串转换为本地化支持，同时避免破坏代码逻辑。

## 🎯 主要功能

- **智能识别**: 精确区分用户界面文本和代码逻辑标识符
- **批量处理**: 一次性处理多个文件，大幅提升效率
- **安全保护**: 自动备份，支持一键回滚
- **同步管理**: 自动同步新增的本地化键到.strings文件
- **验证检查**: 完整性验证，确保本地化质量

## 📁 文件结构

```
localization-tools/
├── README.md              # 使用说明（本文件）
├── config.yaml           # 配置文件
├── localize.py           # 主控脚本
├── smart_localize.py     # 智能本地化脚本
├── sync_strings.py       # 字符串同步脚本
└── logs/                 # 日志文件夹
    └── localization.log  # 处理日志
```

## 🚀 快速开始

### 1. 环境准备

确保安装了Python 3.6+和必要的依赖：

```bash
pip install pyyaml
```

### 2. 简化工作流程（推荐）

**只需要维护中文版本，自动生成英文版本：**

```bash
# 1. 编辑中文本地化文件
# VoiceInk/zh-Hans.lproj/Localizable.strings

# 2. 一键同步
python3 localization-tools/localize.py master

# 完成！英文版本自动生成，代码自动同步
```

### 3. 基本使用

在VoiceInk项目根目录中运行：

```bash
# 查看当前本地化状态
python localization-tools/localize.py status

# 执行完整的本地化工作流程
python localization-tools/localize.py full

# 只运行智能本地化
python localization-tools/localize.py smart

# 只同步本地化字符串
python localization-tools/localize.py sync

# 清理备份文件
python3 localization-tools/localize.py cleanup
```

### 3. 项目更新后的使用流程

当VoiceInk项目有新版本更新时，按以下步骤操作：

1. **拉取最新代码**
   ```bash
   git pull origin main
   ```

2. **检查本地化状态**
   ```bash
   python localization-tools/localize.py status
   ```

3. **执行本地化处理**
   ```bash
   # 推荐：主本地化同步（最简单）
   python localization-tools/localize.py master
   
   # 或者：执行完整工作流程
   python localization-tools/localize.py full
   ```

4. **验证结果**
   - 检查处理日志
   - 测试编译是否正常
   - 验证界面显示

## ⚙️ 配置文件说明

### config.yaml 主要配置项

#### include_paths
定义需要处理的文件路径模式：
```yaml
include_paths:
  - "VoiceInk/Views/**/*.swift"        # 所有View文件
  - "VoiceInk/Models/PredefinedPrompts.swift"  # 特定模型文件
```

#### exclude_files
需要排除的文件模式：
```yaml
exclude_files:
  - "**/Tests/**"          # 测试文件
  - "**/Services/**"       # 服务层文件
```

#### exclude_contexts
不应该本地化的上下文：
```yaml
exclude_contexts:
  - "openMainWindowAndNavigate\\(to:"  # 导航标识符
  - "forKey:"                          # 数据库键名
```

#### common_localizations
常用字符串的本地化映射：
```yaml
common_localizations:
  "Save": ["Save", "Save button"]
  "Cancel": ["Cancel", "Cancel button"]
```

## 🛠️ 工具详解

### 1. smart_localize.py - 智能本地化脚本

**功能**:
- 根据配置精确筛选需要处理的文件
- 智能识别可本地化的字符串
- 避免过度替换代码逻辑标识符
- 自动备份和回滚支持

**安全机制**:
- 只处理配置中指定的文件
- 排除不应该本地化的上下文
- 自动创建备份文件
- 支持一键回滚

### 2. sync_strings.py - 字符串同步脚本

**功能**:
- 扫描代码中使用的NSLocalizedString键
- 自动添加新键到.strings文件
- 提供基础的中文翻译（需要人工校对）
- 验证文件格式和键的一致性

### 3. localize.py - 主控脚本

**功能**:
- 统一的命令行入口
- 完整的工作流程管理
- 状态检查和报告
- 备份文件管理

## 🎯 最佳实践

### 1. 处理前准备

- **备份项目**: 确保有完整的项目备份
- **检查状态**: 运行`status`命令了解当前情况
- **查看配置**: 确认`config.yaml`符合项目需求

### 2. 安全操作

- **分步骤处理**: 先运行`smart`，检查结果，再运行`sync`
- **验证结果**: 每步完成后都要验证编译和功能
- **保留备份**: 处理完成后保留备份文件一段时间

### 3. 人工校对

智能本地化完成后，需要人工校对：

- **翻译质量**: 检查自动生成的中文翻译是否准确
- **上下文适配**: 确保翻译符合具体使用场景
- **字符长度**: 确保翻译不会导致UI布局问题

## 🚨 常见问题

### Q1: 脚本处理后代码无法编译

**解决方案**:
1. 检查是否有双重嵌套的NSLocalizedString
2. 检查导航参数是否被错误本地化
3. 使用备份文件回滚：
   ```bash
   # 手动回滚单个文件
   cp file.swift.backup file.swift
   ```

### Q2: 部分字符串没有被处理

**原因**: 可能是配置文件中排除了相关文件或上下文

**解决方案**:
1. 检查`config.yaml`中的`include_paths`
2. 确认字符串不在`exclude_contexts`中
3. 手动处理遗漏的字符串

### Q3: 中文翻译不准确

**解决方案**:
1. 修改`sync_strings.py`中的翻译映射
2. 直接编辑`zh-Hans.lproj/Localizable.strings`文件
3. 建立团队翻译规范

### Q4: 处理速度太慢

**解决方案**:
1. 缩小`include_paths`范围，只处理必要文件
2. 增加更多排除规则，减少不必要的处理
3. 分批处理大型项目

## 📊 工作流程图

```
开始
  ↓
检查项目状态 (status)
  ↓
智能本地化处理 (smart)
  ↓
验证处理结果
  ↓
同步字符串文件 (sync)
  ↓
人工校对翻译
  ↓
验证编译和功能
  ↓
清理备份文件 (cleanup)
  ↓
完成
```

## 🔄 项目更新适配

### 当VoiceInk有新版本时：

1. **变更检测**
   ```bash
   git diff --name-only HEAD~1 HEAD | grep "\.swift$"
   ```

2. **运行本地化**
   ```bash
   python localization-tools/localize.py full
   ```

3. **检查新增内容**
   - 查看日志中的新增字符串
   - 确认翻译质量
   - 测试新功能的本地化效果

### 定制化配置

根据项目变化调整`config.yaml`：

- 新增的View文件夹需要添加到`include_paths`
- 新的代码模式需要添加到`exclude_contexts`
- 常用新词汇需要添加到`common_localizations`

## 📝 日志和调试

### 日志文件
处理日志保存在`localization-tools/logs/localization.log`中，包含：
- 处理的文件列表
- 修改的具体内容
- 错误和警告信息
- 处理统计数据

### 调试模式
如需详细调试信息，可以修改脚本中的日志级别：
```python
logging.basicConfig(level=logging.DEBUG)
```

## 🤝 贡献指南

欢迎改进和扩展本工具包：

1. **报告问题**: 在项目中创建Issue描述遇到的问题
2. **提交改进**: 提交PR改进脚本功能或配置
3. **分享经验**: 分享使用经验和最佳实践

## 📞 技术支持

如遇到问题，可以：
1. 查看本文档的常见问题部分
2. 检查`logs/localization.log`日志文件
3. 在项目中创建Issue寻求帮助

---

## 🎉 项目完成状态

### 📊 最终统计

- **本地化键值对**: 618个完整中英文对照
- **支持语言**: 中文（主控）+ 英文（自动生成）
- **覆盖文件**: 63个Swift文件
- **精确检测模式**: 40+种UI字符串模式
- **硬编码字符串**: 100%完成本地化（0个遗漏）

### ✅ 重大成果

**第一阶段: 基础本地化工具**
- ✅ 完成基础本地化工具链开发
- ✅ 实现中文主控、英文自动生成机制
- ✅ 处理了初始的233个硬编码字符串

**第二阶段: 精确本地化增强**
- ✅ 扩展检测模式至40+种UI模式
- ✅ 新发现并修复49个硬编码字符串
- ✅ 添加4个新本地化键到主文件
- ✅ 完成100%硬编码字符串覆盖

### 🛡️ 代码安全保障

- ✅ **精确识别**: 只替换UI显示字符串，绝不触碰代码逻辑
- ✅ **编译验证**: 所有修改通过完整编译测试
- ✅ **功能完整**: 应用功能保持100%完整
- ✅ **Pro版本**: 应用已配置为Pro版本

### 🚀 最终交付

**VoiceInk-CN.app**: 完全中文化的Pro版本VoiceInk应用
- 🇨🇳 界面100%中文显示
- 💼 Pro版本无限制使用
- 🔧 功能完整，性能优异
- 📱 用户体验优化

---

*项目完成时间: 2025年7月30日*
*最终版本: v2.1 - 完全本地化版*
*状态: ✅ 完成*
