import asyncio
import re
from pathlib import Path
from unittest.mock import AsyncMock


class FakeInteraction:
    def __init__(self) -> None:
        self.reply = AsyncMock()
        self.followUp = AsyncMock()


async def send_checklist(interaction: FakeInteraction) -> None:
    file_path = Path(__file__).resolve().parents[1] / "docs" / "QA_CHECKLIST.md"
    text = file_path.read_text(encoding="utf-8")
    chunks = re.findall(r"([\s\S]{1,2000})", text)
    if not chunks:
        await interaction.reply(content="QA checklist is empty.", ephemeral=True)
        return
    await interaction.reply(content=chunks[0], ephemeral=True)
    for chunk in chunks[1:]:
        await interaction.followUp(content=chunk, ephemeral=True)


def test_send_checklist_chunks(tmp_path):
    interaction = FakeInteraction()
    asyncio.run(send_checklist(interaction))

    file_path = Path(__file__).resolve().parents[1] / "docs" / "QA_CHECKLIST.md"
    text = file_path.read_text(encoding="utf-8")
    expected_chunks = re.findall(r"([\s\S]{1,2000})", text)

    interaction.reply.assert_called_once_with(
        content=expected_chunks[0], ephemeral=True
    )
    follow_up_calls = interaction.followUp.call_args_list
    assert len(follow_up_calls) == max(0, len(expected_chunks) - 1)
    for call, chunk in zip(follow_up_calls, expected_chunks[1:]):
        assert call.kwargs == {"content": chunk, "ephemeral": True}
