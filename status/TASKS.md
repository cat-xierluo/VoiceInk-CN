# 高阶目标清单

> 根据 AGENTS 协议创建，按优先级从上至下执行。打勾表示已完成。

- [x] 整理根目录文档并迁移到 `docs/` / `status/` 目录
- [x] 清理 `VoiceInk/zh-Hans.lproj/Localizable.strings` 中的冗余与重复键
- [x] 完成 `localization-tools/localize.py` 自动补丁流程（复制上游 → 应用补丁 → 输出差异）
- [ ] 在 CI / pre-commit 中集成 `python3 localization-tools/localize.py status -r`
- [ ] 建立 `docs/ARCHITECTURE.md` 与 `docs/DECISIONS.md`
