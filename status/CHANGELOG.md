# 变更日志

> 参考 Keep a Changelog 格式，按时间倒序记录。

## [Unreleased]

### 新增
- 建立 `docs/ARCHITECTURE.md`、`docs/DECISIONS.md`，记录项目架构与关键决策。
- 创建 `status/TASKS.md`、`status/CHANGELOG.md`、`status/JOURNAL.md` 以符合协作协议。
- 添加 `docs/DOCUMENTATION_INDEX.md` 汇总文档分类。
- `localize.py replay --source` 命令：自动复制上游源码、叠加本地化补丁并输出差异报告。

### 变更
- 迁移根目录文档至 `docs/`，更新 README 链接确保指向新路径。
- 扩展 `localization-tools/localize.py` 支持 `status -r` 报告与 Base 回退逻辑。
- 清理 `VoiceInk/zh-Hans.lproj/Localizable.strings` 中 160 个重复或与英文相同的键，统一由 `en.lproj` 作为比对基准。
- 自动补齐 67 个缺失键并将同值键纳入允许列表，`zh-Hans` 与 `en.lproj` 键数量实现 1:1 对齐。
