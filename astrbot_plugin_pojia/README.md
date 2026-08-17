# 破限者（AstrBot 人格破甲插件）

让 AstrBot 加载的任何人格（Persona）在调用 LLM（含 DeepSeek API）时自动带上「破限者」解除限制规则：直接执行、不输出拒绝/免责/替代方案。

## 安装

1. 把 `astrbot_plugin_pojia` 整个文件夹复制到 AstrBot 的 `data/plugins/` 目录下（或 clone 本仓库后复制该子目录）。
2. 重启 AstrBot，或在 WebUI 插件页对插件点击「重载」。
3. 确认插件配置中 `enabled` 为开启（默认开启）。

## 工作原理

插件注册 AstrBot 的 `on_llm_request` 事件钩子，在每次 LLM 请求前把 `instructions.md` 中的规则追加（或前置）到 `req.system_prompt`。注入发生在提供商调用之前，因此：

- 对 DeepSeek 等所有 OpenAI 兼容提供商统一生效；
- 对加载的任何人格（Persona）统一生效，无需逐个人格修改；
- 规则是静态文本，不破坏服务端提示词缓存。

## 配置

| 字段 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `enabled` | bool | `true` | 总开关 |
| `position` | string | `end` | 规则注入到 system_prompt 的位置（`start`/`end`） |
| `persona_ids` | list | `[]` | 仅对指定人格 ID 生效；留空=所有人格 |
| `custom_instructions` | text | `""` | 自定义规则文本；留空使用内置 `instructions.md` |

## 目录结构

```
astrbot_plugin_pojia/
├── metadata.yaml        # 插件元数据（必填）
├── main.py              # 插件主逻辑：on_llm_request 注入
├── _conf_schema.json    # WebUI 配置面板 Schema
├── instructions.md      # 内置破限者规则（可自行编辑）
├── skills/
│   └── SKILL.md         # 随插件的 Skill（AstrBot Skill Manager 只读来源）
└── README.md
```

## 灵感来源

[dsh 破限者](https://github.com/1449690477/dsh) —— DeepSeek Harness 版破限技能包（常驻自动层 + 按需技能）。