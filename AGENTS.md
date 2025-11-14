# Repository Guidelines

## 项目结构与模块组织
- `VoiceInk/` 存放 macOS 应用源码，包括 SwiftUI 视图、管理器、服务层、资源与本地化文件；`Views/`、`Services/`、`Models/` 各自聚焦界面、业务逻辑与数据模型。
- `VoiceInkTests/` 与 `VoiceInkUITests/` 分别用于单元测试和 UI 自动化；新增模块请在相同分组下补充测试，测试数据放入对应测试目标的 `Resources/`。
- `localization-tools/` 提供 Python 自动化脚本，同步 `zh-Hans.lproj` 与英文资源；日志和备份位于 `localization-tools/logs` 与 `localization-tools/backups`，便于回溯每次同步。
- `whisper.cpp/` 缓存上游语音引擎，构建产物默认输出到 `whisper.cpp/build-apple/whisper.xcframework`；若更换模型，请更新构建脚本注释记录来源。

## 构建、测试与开发命令
- `open VoiceInk.xcodeproj` 在 Xcode 中打开工程，日常开发请选择 VoiceInk scheme。
- `xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug build` 命令行构建，可提前发现缺失资源。
- `xcodebuild test -project VoiceInk.xcodeproj -scheme VoiceInk -destination 'platform=macOS'` 运行全部单元与 UI 测试，建议每次提 PR 前执行。
- `python3 localization-tools/localize.py master` 在修改 `VoiceInk/zh-Hans.lproj` 后刷新本地化字符串。
- `python3 localization-tools/localize.py status` 查看待同步条目，确认没有遗漏或冲突记录后再合并。

## 代码风格与命名规范
- 遵循 Swift API 设计规范：类型使用大驼峰，方法与属性使用小驼峰，尽量采用语义清晰的命名。
- 统一使用四个空格缩进，保持行宽不超过 120 字符，与现有文件保持一致。
- 需本地化的字符串使用 `NSLocalizedString`，键值与英文源保持同步，并维护 `Localizable.strings` 注释。
- 暂未启用自动化格式化或 SwiftLint；提交前请手动检查 import 顺序、空行和 TODO 标记，保持历史一致性。

## 测试准则
- 在 `VoiceInkTests` 中编写新的单元测试；涉及 UI 的流程放入 `VoiceInkUITests`。
- 测试函数命名遵循 `test<功能><行为>` 格式，便于阅读和报告追踪。
- 每次代码或本地化改动后本地运行 `xcodebuild test ...`，出现偶发 UI 失败需排查原因。
- 重点关注转写、快捷键和权限流程的覆盖率，确保不下降。
- 如需模拟麦克风或权限场景，可参考现有测试用例的 mock 对象，并在 PR 描述说明测试环境。

## 提交与 PR 指南
- 采用 Conventional Commit 格式（如 `feat:`、`fix:`、`refactor(localization):`），范围可选但需准确；允许精炼的中文摘要。
- 每次提交仅包含聚焦改动并确保可通过构建；不要提交生成的 `.app` 文件。
- PR 需包含变更摘要、测试说明与关联问题；界面变更请附截图或录屏。
- 涉及 `localization-tools` 或字符串资源时，请请求熟悉本地化的维护者评审。
- 推荐以 `feature/<主题>` 或 `fix/<问题>` 命名分支，便于追踪发布日志。

## 本地化流程
- 在 `VoiceInk/zh-Hans.lproj/Localizable.strings` 编辑中文文案，保留段落注释作为上下文。
- 使用 `python3 localization-tools/localize.py status` 同步前检查当前状态；如需导出差异报告，可追加 `-r` 生成 Markdown 文件。
- 上游发布新版本后先运行 `python3 localization-tools/localize.py extract`，自动生成最新 `Base.lproj` 并备份旧文件（若工具缺失，脚本会提示手动步骤）。
- 运行 `localize.py master`（或在上游改动较大时执行 `full`）并审阅差异及 `localization-tools/backups` 中的备份。
- 同步完成后重新构建应用，确认菜单、提示与 Pro 功能显示正确。
- 若发现缺失键或冲突，在 `localization-tools/logs` 查找具体记录，并提交修复说明以便后续维护。
- 如遇上游接口更新或文案策略调整，请在 PR 中同步记录背景，方便其他贡献者延续维护。
- 定期在 `localization` 分支执行 `git fetch upstream && git rebase upstream/main`；无冲突的中文化提交会自动重放，冲突文件重点关注 `L10n.swift` 与 `.strings` 资源。
- 建议将本地化步骤写入脚本（复制上游源码 → 运行替换/生成 → 覆盖工作目录），确保即使上游重构也能一键恢复中文版本。

## 参考文档
- `LOCALIZATION_PLAN.md`：上游同步与本地化整体方案
- `ROADMAP.md`：近期路线图与优先级
- `PROGRESS.md`：阶段性成果与待办跟进
