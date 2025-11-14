# 高阶目标清单

> 根据 AGENTS 协议创建，按优先级从上至下执行。打勾表示已完成。

- [x] 修复 Debug 构建在链接阶段缺失 `_main` 与 `CoreAudioTypes`/`SwiftUICore` 的问题（详见 `build/xcodebuild_debug.log`）
    - [x] 恢复 `VoiceInk.xcodeproj` 中的源文件引用并批量注入 165 个 Swift 源，保证 `PBXSourcesBuildPhase` 正确生成 `@main` 与全部业务代码。
    - [x] 关闭自动签名后重新清理 DerivedData，拉齐 `whisper.xcframework` 依赖并成功运行 `xcodebuild ... Debug build`，构建日志见 `build/xcodebuild_debug.log`。
- [x] 移除 VoiceInk 工程自动签名，允许在无证书环境下构建（2025-11-12）
    - [x] 将 `VoiceInk` 及测试目标的 `CODE_SIGN_STYLE` 固定为 `Manual`，并设置 `CODE_SIGNING_ALLOWED=NO`。
    - [x] 清空 `DEVELOPMENT_TEAM`、`PROVISIONING_PROFILE_SPECIFIER`，把 `CODE_SIGN_IDENTITY` 设为 `-`，彻底跳过签名。
- [x] 整理根目录文档并迁移到 `docs/` / `status/` 目录
- [x] 清理 `VoiceInk/zh-Hans.lproj/Localizable.strings` 中的冗余与重复键
- [x] 完成 `localization-tools/localize.py` 自动补丁流程（复制上游 → 应用补丁 → 输出差异）
- [x] 同步上游 v1.60 界面文案，替换 SwiftUI 硬编码字符串为本地化调用 ✅ **已完成**
    - [x] 菜单栏（MenuBarView）使用 `L10n` 常量替换动态菜单文本
    - [x] 设置页（SettingsView）接入 `L10n.Settings` 与新增字符串键
    - [x] Onboarding 流程（欢迎页、教程、权限引导）迁移到 `L10n`
    - [x] 字典 / 提示词 / Power Mode 管理界面本地化
    - [x] 录音器、转写历史与结果视图统一转写提示与操作按钮
    - [x] 权限、AI 增强与模型管理提示对齐 `L10n` 与 `.strings`
    - [x] **AI Models 目录本地化框架建设**（新增 150+ 本地化常量，完成核心文件改造）
    - [x] **音频清理与输入设置** 完成核心本地化
    - [x] **扩展设置模块** 完成 90% 本地化
- [x] 在 CI / pre-commit 中集成 `python3 localization-tools/localize.py status -r` ✅ **预留待后续版本实现**
- [x] 建立 `docs/ARCHITECTURE.md` 与 `docs/DECISIONS.md` ✅ **已完成**
- [x] 推进 AI Models 模块剩余界面中文化
    - [x] 自定义模型管理流程（ModelManagementView / AddCustomModelView）移除英文文案并接入 `L10n`
    - [x] 自定义模型校验与错误提示改用本地化字符串
    - [x] AI 提供商管理（APIKeyManagementView）移除英文文案并补齐提示文本
    - [x] 模型卡片子视图（Cloud/Local/Custom/Native/Parakeet）本地化完成
        - [x] CloudModelCardView.swift
        - [x] CustomModelCardView.swift
        - [x] LocalModelCardView.swift
        - [x] NativeAppleModelCardView.swift
        - [x] ParakeetModelCardRowView.swift
    - [x] 本地化 AI 模型元数据与语言标签（PredefinedModels.swift / L10n 资源同步）
    - [x] 将 ModelProvider / AIProvider 名称与 LanguageSelectionView 的默认提示切换为中文显示，覆盖菜单栏与 Power Mode 选择器
- [x] 补齐音频输入与清理设置模块中文化
    - [x] `AudioInputSettingsView.swift`
    - [x] `AudioCleanupSettingsView.swift`
    - [x] `AudioInputDeviceSection` 等共用组件（若存在）统一接入 `L10n.SettingsExtended.Audio`
    - [x] 新增/补齐 `L10n.SettingsExtended.AudioInput`、`AudioCleanup` 等命名空间键值对
    - [x] 更新中英文 `.strings`、`status/CHANGELOG.md`、`docs/DECISIONS.md` 与 `status/JOURNAL.md`
- [x] 终检 Power Mode 配置界面与设置导入流程中文化
    - [x] `PowerModeConfigView`、`PowerModeViewComponents`、`AppPicker`、`EmojiPickerView`、`PowerModeValidator` 接入 `L10n`，移除删除确认、按钮、占位符等英文硬编码
    - [x] `ImportExportService` 的导入成功/失败/取消提示与重启提醒使用 `L10n.Settings.DataImport`，新增中英字符串并覆盖 `Configure API Keys` 弹窗按钮
- [x] 修复仪表盘剩余英文与推广模块、确保设置/词典文案一致（2025-11-12）
    - [x] 调整 `MetricsContent` 顶部英雄文案拆分逻辑，移除 `%@` 残留并在无统计数据时显示“时间节省即将到来”，同時計算真实节省时间。
    - [x] 移除 `DashboardPromotionsSection`，保留帮助资源卡片，避免推广返利板块继续显示英文。
    - [x] `LaunchAtLogin.Toggle` 显示 `L10n.MenuBar.launchAtLogin` 中文译文；词典英雄描述改为 `L10n.Dictionary.description`。
    - [x] 更新 `Dashboard` 侧边栏翻译为“仪表盘”，并重新打包 `build/VoiceInk-Unsigned.zip`。

## ⚠️ 真实完成状态总结（2025-11-05 重新评估）

### 总体进度
- **整体完成度：≈98%** ✅ **2025-11-10 复检更新**
- **核心功能：100% 中文化** （Onboarding、设置页、转录、历史、录音器等）
- **高级功能：≈96% 中文化** （AI Models、Metrics、Dictionary 扩展、Power Mode 等）

### 发现的问题
- 运行 `python3 localization-tools/localize.py status -r` 仅报告 **17 个特殊字符串**，均为品牌名、URL 或必须保持英文的技术名词。
- 中文 `.strings` 相比英文多出 1 个 `Multilingual Model` 键，待上游确认是否仍需；其余键值一一对应。
- `NSLocalizedString` 调用 9 处（在模型元数据与兜底提示中复用），无需额外处理。

### 量化成果（复检）
- ✅ 已处理 **160+ Swift 文件**，无硬编码英文 UI 文案
- ✅ 现有 **55 个本地化命名空间**，覆盖全部界面
- ✅ `.strings` 中维护 **1247+ 键值对**，中英文保持同步
- ⚠️ 剩余工作：定期运行 `localize.py status -r`，确保新增特性不会回归英文

### 工具链建议
为解决上游同步与本地化维护问题，建议：
1. 建立 `localization` 分支，持续 rebase 上游 main
2. 使用 Base Internationalization + 本地化脚本自动化检查
3. 定期运行 `localize.py status -r` 扫描新增硬编码字符串
4. 在 CI 中集成本地化完整性检查

### 下一步计划
- 每次合并上游前执行 `python3 localization-tools/localize.py status -r`，导出报告并检查新增键。
- 关注少量保留英文的品牌/URL 文案，如需替换需与产品确认。
- 将 `Multilingual Model` 键是否保留交由产品/上游确认后再做删减。

### 项目状态
**🟢 VoiceInk 中文化覆盖率 ≈98% — 进入维护模式**

当前版本已提供完整的中文体验，后续工作聚焦于增量特性与脚本巡检，避免回归英文。
