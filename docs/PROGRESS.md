# 项目进度总览

## 当前状态（2025-10-20）
- `docs/` 目录囊括 `AGENTS.md`、`LOCALIZATION_PLAN.md`、`ROADMAP.md`、`PROGRESS.md`、`ARCHITECTURE.md`、`DECISIONS.md` 等核心文档，README 已完成索引更新。
- Swift 代码内的侧边栏与窗口文案集中到 `VoiceInk/L10n.swift`；`Base.lproj/Localizable.strings` 与 `zh-Hans.lproj` 保持同步。
- `localization-tools/localize.py` 支持 `extract`、`status -r` 以及 `replay --source`，可复制上游源码并自动重放本地化补丁；`docs/DOCUMENTATION_INDEX.md` 记录全部文档分类。

## 已完成工作
- **文档建设**：新增并整理 `AGENTS.md`、`LOCALIZATION_PLAN.md`、`ROADMAP.md`、`PROGRESS.md`，补充 `ARCHITECTURE.md`、`DECISIONS.md` 与文档索引。
- **代码本地化改造**：将侧边栏、窗口与许可证视图的硬编码文案迁移至 `L10n` 常量；补齐 Base/中文资源。
- **工具脚本增强**：`localize.py` 增加 Base 提取、差异分析、报告导出、补丁重放等能力。
- **流程提示**：在文档中说明 rebase 同步、脚本化补丁、差异报告等操作，方便非开发贡献者跟进。

## 进行中 / 待办事项
- **上游构建环境**：本地缺少可运行的 `extractLocStrings`（Xcode 插件问题），需在具备完整 Xcode 的机器执行 `python localization-tools/localize.py extract` 或手动运行 `xcodebuild`。
- **字符串差异清理**：`zh-Hans` 已与 `en.lproj` 键数量对齐；持续关注新增键并维护白名单。
- **脚本自动化扩展**：根据路线图实现“复制上游源码 → 应用补丁 → 输出差异”的一键流程，并接入术语库预填。
- **测试与 CI**：设计 smoke test/UITest 覆盖关键中文界面；在 CI 或 pre-commit 中集成 `localize.py status` 检查。

## 下一步建议
1. 在装有完整 Xcode 的环境运行 `localize.py extract`，验证自动提取流程；若失败，记录手动步骤并更新文档。
2. 利用最新 `status -r` 报告清理冗余或未翻译键，形成“差异 → 翻译 → 复核”的例行流程。
3. 迭代 `localization-tools`，实现补丁重放与术语记忆功能，为未来上游重构提供快速自动化支持。
