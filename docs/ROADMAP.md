# VoiceInk-CN 路线图

## 项目愿景
构建一个与上游 VoiceInk 持续同步、体验完全中文化且易于维护的 macOS 语音转写应用。通过规范化的本地化流程、自动化工具和测试保障，缩短上游发布到中文版更新的周期。

## 里程碑一：国际化基础（进行中）
- [x] 将侧边栏、菜单栏与设置页的硬编码文案替换为 `L10n` 常量，并补齐中英文 `.strings`。
- [ ] 完成剩余 SwiftUI 视图的文案封装：
  - [ ] Onboarding 流程（`OnboardingView`, `OnboardingTutorialView`, `OnboardingPermissionsView` 等）
  - [ ] 字典/提示词管理（`Dictionary*`, `PromptEditorView`, `PowerModeView`）
  - [ ] 录音与转写结果组件（`Recorder`, `TranscriptionCard`, `TranscriptionHistoryView`）
  - [ ] 权限与增强设置（`PermissionsView`, `EnhancementSettingsView`, `AIService` 相关提示）
- [ ] 启用 Xcode Base Internationalization，并固定 `Base.lproj`/`zh-Hans.lproj` 同步流程。
- [ ] 整理历史中文翻译至术语库，建立中英文键值对映射。

> 建议顺序：先处理用户可见频率最高的 Onboarding/Permissions → 字典与提示词 → 剩余结果视图。每完成一个区域，即可复用 `status/TASKS.md` 子项做勾选，并在 `L10n` 中补齐键值。

## 里程碑二：本地化自动化工具（计划中）
- 扩展 `localization-tools/localize.py`，集成 `xcrun extractLocStrings` 或 `genstrings`。
- 对比 Base 与 `zh-Hans` 字符串，输出缺失/待确认清单，并支持 glossary 预填。
- 增加命令 `python3 localization-tools/localize.py status|master|full` 的日志输出与错误提示。
- 将中文化“补丁”整理为脚本化流程：从上游源码复制到临时目录 → 执行定位替换/资源生成 → 覆盖工作目录，可随时重放。

## 里程碑三：质量保障（计划中）
- 为关键流程补充 `VoiceInkUITests`，覆盖菜单、权限、转写、快捷键等中文文案。
- 配置 CI 或 pre-commit 检查：若 Base 键缺少中文翻译即阻断提交。
- 建立 smoke test 脚本（命令行构建 + 关键 UI 流程手册），确保每次同步后可快速回归。

## 里程碑四：同步与发布流程（计划中）
- 定义上游同步节奏（如每月一次或跟随正式版本），并记录在发行说明中。
- 在 PR 模板中增加“本地化同步”检查项和影响说明。
- 整理发行打包流程：构建 VoiceInk-CN.app、校验签名/权限、更新下载链接与变更日志。
- 文档化上游重构处理方法（rebase、脚本重放、差异审阅），让非开发向贡献者也能执行同步。
