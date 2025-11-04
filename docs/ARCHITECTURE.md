# 项目架构概述

## 1. 应用层结构
- **VoiceInk/**：主应用源代码，遵循 SwiftUI + MVVM 风格。
  - `Views/`：界面组件及导航（如 `ContentView`, `LicenseManagementView`）。
  - `Services/`：业务服务与系统集成（如 `ActiveWindowService`, `ImportExportService`）。
  - `Models/`：数据模型与本地存储实体（SwiftData `Transcription` 等）。
  - `Whisper/`：语音识别状态与模型管理（`WhisperState`、模型查询）。
  - `Resources/`：脚本、声音及附加资源。
  - `zh-Hans.lproj` / `Base.lproj`：本地化字符串资源。
- **VoiceInkTests/**、**VoiceInkUITests/**：单元与 UI 测试目标，目录结构与源代码保持平行。

## 2. 支撑组件
- **localization-tools/**：本地化自动化脚本集合。
  - `localize.py`：入口脚本，提供 `extract`、`status`、`full` 等命令。
  - `localizer.py` / `master_localizer.py` / `sync_strings.py`：字符串提取与替换的核心逻辑。
  - `logs/`、`backups/`、`generated/`：记录执行日志、备份与差异报告。
- **whisper.cpp/**：第三方语音识别引擎源码及构建产物（不直接纳入应用二进制）。

## 3. 运行流程
1. 应用入口 `VoiceInkApp` 初始化服务（Whisper、Hotkey、MenuBar、Updater）。
2. `ContentView` 通过 `NavigationSplitView` 驱动主界面，侧边栏项由 `L10n.Sidebar` 提供本地化文本。
3. 各功能页（转写、模型管理、权限、许可证等）使用对应的 ViewModel/Service 访问数据层或系统 API。
4. 本地化：所有展示文本统一通过 `L10nItem` 调用 `NSLocalizedString`，避免散落的硬编码。
5. 自动化脚本可在同步上游后运行 `localize.py full`，刷新 Base 字符串、同步中文资源并输出报告。

## 4. 数据与存储
- **SwiftData**：`Transcription` 等模型存储于 `Application Support/com.prakashjoshipax.VoiceInk/default.store`。
- **设置与偏好**：`UserDefaults` 用于快捷键、复制行为等轻量配置。
- **文件资源**：音频、模型文件位于 `Library/Application Support/VoiceInk/` 下，由服务层统一管理。

## 5. 测试与质量保障
- 单元测试覆盖关键服务逻辑，UI 测试聚焦主要交互流程。
- 建议在合并前运行 `xcodebuild test -scheme VoiceInk -destination "platform=macOS"`。
- 本地化脚本提供 `status -r` 报告，协助发现缺失或重复键；未来计划引入 CI 检查。

## 6. 本地化管线
1. `extract`：调用 `xcrun extractLocStrings`（如环境可用）生成最新 `Base.lproj`。
2. `status`：比较 Base 与 `zh-Hans`，输出缺失键、重复键、未翻译项。
3. `master/full`：运行智能替换与字符串同步，生成备份与日志。
4. 手动审阅差异后提交，确保 `L10n.swift` 与 `.strings` 文件保持一致。
