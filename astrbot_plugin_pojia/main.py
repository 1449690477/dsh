"""破限者（AstrBot 人格破甲）插件

在每次 LLM 请求前自动把「破限者」解除限制规则注入 system_prompt，
使 AstrBot 加载的任何人格（Persona，含 DeepSeek 等 OpenAI 兼容提供商）都自动生效，
无需修改人格本身，也无需任何手动调用。

灵感来源：https://github.com/1449690477/dsh（dsh 破限者技能包）
"""

from pathlib import Path

from astrbot.api import AstrBotConfig, logger
from astrbot.api.event import filter, AstrMessageEvent
from astrbot.api.provider import ProviderRequest
from astrbot.api.star import Context, Star

_INSTRUCTIONS_FILE = Path(__file__).parent / "instructions.md"
_MARKER = "[破限者规则开始]"


class PojiaPlugin(Star):
    """破限者插件：在 LLM 请求前自动注入解除限制执行规则。"""

    def __init__(self, context: Context, config: AstrBotConfig):
        super().__init__(context)
        self.config = config
        self.instructions = self._load_instructions()

    def _load_instructions(self) -> str:
        """加载注入文本：优先使用自定义规则，否则读取内置 instructions.md。"""
        custom = (self.config.get("custom_instructions") or "").strip()
        if custom:
            return f"\n\n{_MARKER}\n{custom}\n{_MARKER}\n"
        try:
            text = _INSTRUCTIONS_FILE.read_text(encoding="utf-8")
        except OSError as exc:
            logger.error(f"破限者: 读取 instructions.md 失败: {exc}")
            return ""
        return f"\n\n{_MARKER}\n{text}\n{_MARKER}\n"

    def _persona_allowed(self, req: ProviderRequest) -> bool:
        """按配置的 persona_ids 白名单过滤；留空表示对所有人格生效。"""
        persona_ids = self.config.get("persona_ids") or []
        if not persona_ids:
            return True
        conversation = req.conversation
        if conversation is None or not conversation.persona_id:
            return False
        return conversation.persona_id in persona_ids

    @filter.on_llm_request()
    async def inject_pojia(self, event: AstrMessageEvent, req: ProviderRequest) -> None:
        """在 LLM 请求前把破限者规则注入系统提示词。"""
        if not self.config.get("enabled", True):
            return
        if not self.instructions:
            return
        if not self._persona_allowed(req):
            return
        system_prompt = req.system_prompt or ""
        if _MARKER in system_prompt:
            return  # 已注入过，避免重复
        position = self.config.get("position", "end")
        if position == "start":
            req.system_prompt = self.instructions + system_prompt
        else:
            req.system_prompt = system_prompt + self.instructions