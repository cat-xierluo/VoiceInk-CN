# 关键决策记录

> 使用轻量 ADR 记录影响架构或流程的决定。按时间倒序排列。

## 2025-11-13 — 恢复指标页节省时间算法与英文版一致
- **背景**：为了避免长时间未停止的录音稀释“节省时间”，此前在 `MetricsContent` 中对 `Transcription.duration` 与估算语速取最小值。用户验证后发现节省值明显低于英文原版，希望保持原先的统计口径。
- **决策**：移除对录音时长的裁剪逻辑，仅在缺失真实 `duration` 时按 120 WPM 估算，确保 `timeSaved` 始终等于“打字时间减真实说话时间”，与上游英文版一致。
- **影响**：仪表盘英雄区展示的节省时间会回到原先的较大数值，并与英文用户看到的指标匹配；若录音忘记停止，节省值会相应降低，但不会再被强制裁剪。
- **状态**：已实施。

## 2025-11-12 — 关闭自动签名以便本地构建
- **背景**：命令行执行 `xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug build` 时因 `VoiceInk` 目标仍绑定 `Apple Development` 身份并启用自动签名，缺失 Provisioning Profile 会直接中断构建，影响后续中文化巡检。
- **决策**：
  1. 将 `VoiceInk`、`VoiceInkTests`、`VoiceInkUITests` 的 `CODE_SIGN_STYLE` 统一固定为 `Manual`，把 `CODE_SIGN_IDENTITY[sdk=macosx*]` 设置为 `-` 并清空 `DEVELOPMENT_TEAM`。
  2. 新增 `CODE_SIGNING_ALLOWED = NO` 与 `CODE_SIGNING_REQUIRED = NO`，确保 Debug/Release 构建都跳过签名流程。
  3. 保留 entitlements 与 bundle 设置，未来若需要正式签名只需在 Xcode UI 中重新指定团队与证书即可恢复。
- **影响**：`xcodebuild` 不再因为缺少描述文件而失败，可直接生成未签名包用于本地验证；后续如需分发仍可在具备证书的机器上恢复签名。
- **状态**：已实施。

## 2025-11-13 — 恢复 Xcode 工程的源文件引用
- **背景**：`VoiceInk.xcodeproj` 仅保留了 FileSystem Synchronized 根目录，没有显式 `PBXBuildFile`/`PBXFileReference`，导致 `xcodebuild` 虽然能解析项目却在链接阶段缺少 `_main`，始终无法生成可执行文件。
- **决策**：
  1. 扫描 `VoiceInk/` 目录下全部 165 个 `.swift` 文件，批量生成对应的 `PBXFileReference`、`PBXBuildFile` 与 `files` 条目写入 `PBXSourcesBuildPhase`，确保 `VoiceInk.swift` 的 `@main` 被编译。
  2. 对包含空格或特殊字符（如 `+`）的 `name`/`path` 进行转义，避免 `project.pbxproj` 在解析时再次出现 `missing semicolon` 错误。
  3. 保留 `PBXResourcesBuildPhase`、依赖与签名设置不变，仅同步 `PBXFileReference` 与 `PBXSourcesBuildPhase`，减少对其他模块的影响。
- **影响**：`xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug build` 成功产出未签名的 `VoiceInk.app`，可继续执行后续测试或打包；构建日志记录在 `build/xcodebuild_debug.log` 供复查。
- **状态**：已实施。

## 2025-11-12 — 仪表盘英雄文案与推广模块收尾
- **背景**：用户在最新截图中仍看到 Dashboard 英雄区显示 `%@` 占位符与“时间节省即将到来”串联到同一行，推广返利卡片保持英文、设置页 `Launch at Login` 与词典英雄描述也未切换到中文，导致体验割裂。
- **决策**：
  1. 将 `L10n.Metrics.savedWithVoiceInk` 改写为独立前缀，并在 `MetricsContent` 中根据是否存在统计数据决定展示“真实节省时间”或 fallback，彻底移除 `%@` 残留；同时保留 `with VoiceInk` 作为可选后缀。
  2. 移除 `DashboardPromotionsSection`，仅保留帮助资源卡片，满足“仪表盘不展示推广返利”的诉求；同步把 Sidebar “Dashboard” 的译文改为“仪表盘”。
  3. `LaunchAtLogin.Toggle` 强制传入 `L10n.MenuBar.launchAtLogin`，词典英雄描述改用 `L10n.Dictionary.description`，确保设置/词典界面与其它模块一样读取中文资源，并重新打包 `build/VoiceInk-Unsigned.zip` 供验证。
- **影响**：仪表盘的节省时间数据以中文正常展示，无统计数据时也能输出友好的提示；推广位被隐藏后不再出现英文模块；设置、词典等界面维持完全中文化。最新无签名包遵循同一体验，可直接分享给测试同学复检。
- **状态**：已实施。

## 2025-11-10 — 中文化巡检与维护策略
- **背景**：在完成 Power Mode/AI 模型/历史等主要界面本地化后，仍需确认是否存在英文残留，并决定后续维护方式。
- **决策**：
  1. 运行 `python3 localization-tools/localize.py status -r` 作为标准巡检步骤，生成报告归档于 `localization-tools/generated/reports/`，若输出仅含品牌/URL 等白名单项目，则视为通过。
  2. 对报告中唯一的多余键 `Multilingual Model` 暂不删除，待上游确认是否仍会引用；将其列为追踪事项。
  3. 将 `status/TASKS.md` 真实完成度更新为 ≈98%，并将项目状态调整为维护模式，提醒后续贡献者以脚本巡检作为回归检测。
- **影响**：中文化状态有据可查，后续代理可直接复用 `localize.py status -r` 验证；任务与日志同步体现“巡检已完成、进入维护阶段”，避免重复劳动。
- **状态**：已实施。

## 2025-11-09 — 本地化 AI 模型元数据与提供商名称
- **背景**：即便视图层已接入 `L10n`，AI Models 中的卡片、语言选择器与菜单栏仍显示英文，因为 `PredefinedModels` 的 `displayName`/`description` 以及语言字典都直接返回英文常量，`ModelProvider`/`AIProvider` 也在 UI 中直接使用 `rawValue`。
- **决策**：
  1. 在 `PredefinedModels` 中将模型名称、描述与语言字典视为本地化键，通过 `NSLocalizedString` 初始化，新增缺失的 Parakeet、Nova-3 Medical、Gemini 2.5、Soniox 等字符串到 `en.lproj` / `zh-Hans.lproj`。
  2. 扩展 `ModelProvider` 与 `AIProvider`，提供 `localizedName` 供菜单栏、Power Mode 与 APIKey 视图复用，避免再出现英文提供商名称。
  3. 为 `LanguageSelectionView`、`ImportedLocalModel` 等默认路径补充本地化兜底，确保没有模型时依然输出中文提示。
- **影响**：模型卡片、选择器与 API 管理界面均可自动根据当前语言展示中文；未来新增模型时只需在 `.strings` 中补充键值即可，减少重复改动视图层的工作量。
- **状态**：已实施。

## 2025-11-09 — 音频输入与清理设置中文化策略
- **背景**：`AudioInputSettingsView` 的输入模式卡片和 `AudioCleanupSettingsView` 的清理弹窗仍混杂英文（模式名称依赖 `rawValue`，清理提示使用英文复数后缀），在中文界面中突兀。
- **决策**：
  1. 为 `AudioInputMode` 提供 `localizedTitle/Description`，并在 `L10n.SettingsExtended.AudioInput.Mode` 中集中维护对应字符串，确保卡片标题/说明与语言切换同步。
  2. 调整音频清理提示，将天数描述抽象为 `%d day(s)` 键，通过 `String(format:)` 生成，去掉手写英文复数逻辑，并统一使用 `L10n.Common` 中的按钮文案。
  3. 扩展中英文 `.strings`，补齐 `%d day(s)` 等占位符，保证确认/结果弹窗可完整显示中文语句。
- **影响**：音频输入与清理设置界面实现全量本地化，告别 raw value 与英文后缀，提升设置页一致性。
- **状态**：已实施。

## 2025-11-09 — Metrics 与词典设置中文化策略
- **背景**：Metrics 仪表板及 Performance 分析、Time Efficiency、推广卡片等仍大量使用英文硬编码；词典设置页的分区标题/说明也固定为英文，导致中文界面体验割裂。
- **决策**：
  1. 为 Metrics 新增 `L10n.Metrics.Promotions/Setup/Performance/TimeEfficiency` 命名空间，覆盖推广卡片、系统信息、性能指标与效率对比等全部文案；配套更新 `en`/`zh-Hans` 字符串。
  2. 重构 `MetricsSetupView`/`TimeEfficiencyView`/`PerformanceAnalysisView`/`DashboardPromotionsSection` 等视图，统一改用 `L10n` 常量与格式化字符串，避免再出现 raw value。
  3. 扩展 `L10n.Dictionary`，为词典分区标题和说明提供本地化常量，`DictionarySettingsView` 根据选择动态显示中文描述。
- **影响**：Metrics 模块与词典设置页在中英文界面间保持一致，推广/性能/效率文案可随语言切换，后续新增内容也可复用命名空间。
- **状态**：已实施。

## 2025-11-10 — Components 与 License 视图中文化收尾
- **背景**：组件目录与许可证页面仍存在“Trial Ending Soon”“Add new prompt”“Changelog”等英文硬编码，影响整体体验。
- **决策**：
  1. 为 Components/Licenses 补充缺失的 `L10n.Items`，包括提示按钮、试用状态与许可证卡片上的标签，统一使用中英双语资源。
  2. `LicenseManagementView`、`TrialMessageView`、`PromptSelectionGrid` 等视图改用新增常量，移除字符串拼接中的英文。
- **影响**：所有通用组件与许可证界面在中英文环境下保持一致，后续再新增文案可直接复用现有命名空间。
- **状态**：已实施。

## 2025-11-06 — 聚焦 AI 模型自定义流程中文化
- **背景**：用户反馈成品应用在 AI 模型管理区域仍显示大量英文，尤其是自定义模型增删流程与校验提示，影响当前版本体验。
- **决策**：
  1. 优先处理 `ModelManagementView` 与 `AddCustomModelView`，将筛选按钮、删除确认、导入说明等 UI 文案全部迁移至 `L10n`。
  2. 扩展 `L10n.AIModels.CustomModel` 命名空间，同步补充 `en.lproj` / `zh-Hans.lproj` 中缺失的 14 条键值对。
  3. 调整 `CustomModelManager` 校验逻辑，返回本地化错误信息，为后续 UI 弹窗直接复用。
- **影响**：自定义模型相关流程在最新构建中可完整显示中文，减少关键路径英文残留；同时为剩余 AI Models 子视图的本地化提供命名空间与资源基础。
- **状态**：已实施，后续需继续覆盖 APIKeyManagementView 与各模型卡片。

## 2025-11-05 — 扩展 v1.60 本地化覆盖
- **背景**：上游升级到 1.60 后，新增界面与菜单仍保留英文硬编码，原有 1.42 版本的本地化映射无法直接复用。
- **决策**：
  1. 在 `status/TASKS.md` 新增目标，系统性梳理 SwiftUI 视图中的硬编码英文，逐步改用 `L10n` 与 `.strings` 资源。
  2. 为动态插值文案补充占位符键值（如“Transcription Model: %@”），确保 SwiftUI `Text`/`Button` 可自动匹配翻译。
- **影响**：保持应用在最新版本中仍可打包中文界面，同时为后续脚本提取提供完整字典，降低遗漏风险。
- **状态**：进行中。

## 2025-10-20 — 本地化集中化与脚本管线
- **背景**：上游项目频繁更新，原仓库存在大量散落的中文硬编码与无法复现的手工替换。
- **决策**：
  1. 引入 `VoiceInk/L10n.swift` 与 `L10nItem`，所有 UI 文案统一从常量访问，配合 `Base.lproj`/`zh-Hans.lproj` 资源。
  2. 扩展 `localization-tools/localize.py`，新增 `extract`、`status -r` 等命令，支持 Base 提取、差异报告与全流程执行。
  3. 重构文档结构：将说明文档集中到 `docs/`，新增 `status/` 目录维护任务、变更、日志。
- **影响**：本地化差异可通过脚本复现；文档为后续代理或贡献者提供统一上下文。
- **状态**：已实施，后续需补充 CI 与术语库自动化。

## 2025-11-12 — 中文化收尾与遗留问题记录
- **背景**：大部分界面已通过 L10n/`zh-Hans.lproj` 完成翻译，但用户复检仍发现仪表盘（翻译成“仪表板”）、推广返利卡片、权限文案与“Launch at Login”等细节存在英文或不准确的组合。
- **决策**：
  1. 分拆 Dashboard 顶部的 “You have saved %@ with VoiceInk”/“with VoiceInk” 字符串，统一中文翻译，并将 “Dictated %@ words across %d %@.” 改写为 “共口述 %@ 个单词，覆盖 %d %@。”；未来需要在代码层做格式化校正。
  2. 权限页面 `PermissionCard` 全部接入 `L10n.Permissions`，并新增辅助信息 `accessibilityInfo`、`screenRecordingInfo`，以便中文提示与按钮一致；词典页标题去掉多余句号并补充 “Manage VoiceInk settings and preferences” 的译文。
  3. 移除 Dashboard “推广返利”模块，避免中文界面出现英文内容；设置页的 “Launch at Login” 需要接入 `L10n.Settings.launchAtLogin` 显示中文。
- **影响**：记录当前尚未收尾的中文化问题，为后续补丁提供明确的待办；也提醒构建时要使用最新 `Localizable.strings` 才能看到正确译文。
- **状态**：已由“2025-11-12 — 仪表盘英雄文案与推广模块收尾”落地，保留此记录作为原始问题描述。
