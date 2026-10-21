import sys
from datetime import UTC, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import weekly_report as wr  # noqa: E402

NOW = datetime(2026, 10, 26, 12, 0, tzinfo=UTC)


def pr(number: int, created: datetime, repo: str = "tpl") -> wr.OpenPR:
    return wr.OpenPR(
        repo, number, f"PR {number}", f"https://x/{number}", "dependabot[bot]", created
    )


def test_iso_week() -> None:
    assert wr.iso_week(NOW) == "2026-W44"


def test_stale_prs_filters_by_age_and_sorts_oldest_first() -> None:
    prs = [
        pr(1, datetime(2026, 10, 25, tzinfo=UTC)),
        pr(2, datetime(2026, 10, 20, tzinfo=UTC)),
        pr(3, datetime(2026, 10, 22, tzinfo=UTC)),
    ]
    assert [p.number for p in wr.stale_prs(prs, NOW, 3)] == [2, 3]


def test_render_summary_hides_inactive_repos() -> None:
    activity = [
        wr.RepoActivity("busy", 5, 1, 1, 0, 0, ["v0.2.0"]),
        wr.RepoActivity("quiet", 0, 0, 0, 0, 0, []),
    ]
    md = wr.render_summary(activity, [], NOW)
    assert "| busy | 5 | 1 | 1 | 0 | 0 | v0.2.0 |" in md
    assert "quiet" not in md
    assert "**Total commits:** 5" in md
    assert "_None._" in md


def test_render_summary_without_activity_lists_open_prs() -> None:
    md = wr.render_summary([], [pr(7, datetime(2026, 10, 19, tzinfo=UTC))], NOW)
    assert "_No activity this week._" in md
    assert "[tpl#7](https://x/7) PR 7 (by dependabot[bot], 7 days old)" in md


def test_render_reminder() -> None:
    md = wr.render_reminder([pr(4, datetime(2026, 10, 21, tzinfo=UTC))], NOW, 3)
    assert "**3+ days**" in md
    assert "- [ ] [tpl#4](https://x/4) PR 4 — 5 days, by dependabot[bot]" in md


def test_main_rejects_unknown_mode() -> None:
    assert wr.main([]) == 2
    assert wr.main(["nope"]) == 2
