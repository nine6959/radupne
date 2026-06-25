# 다른 컴퓨터에 스킬 설치하기

스킬이 없는 새 컴퓨터에 **이 6종 스킬을 똑같이** 설치하는 방법입니다.
두 가지 방법이 있어요. 편한 쪽을 고르세요.

---

## 방법 A. 설치 스크립트 한 번 실행 (가장 간단) ⭐

`scripts/install-skills.sh` 파일 **하나만** 새 컴퓨터로 복사한 뒤 실행하면 됩니다.
인터넷에서 원본 스킬을 받아 자동 설치해요. (필요: `curl`, `tar` — macOS/Linux 기본 포함)

```bash
# 1) 개인 폴더에 설치 → 그 컴퓨터의 "모든 프로젝트"에서 사용 (추천)
bash install-skills.sh

# 2) 특정 프로젝트에만 설치 → 그 폴더에서 실행
bash install-skills.sh --project

# 3) 원하는 위치에 설치
bash install-skills.sh --target /원하는/경로
```

설치 후 Claude Code를 열면 스킬이 자동으로 인식됩니다.

> **Windows 사용자**: "Git Bash" 또는 "WSL"을 열고 위 명령을 그대로 실행하세요.

---

## 방법 B. Claude Code 공식 플러그인으로 설치

관리(업데이트·삭제)가 편한 방식입니다. Claude Code 안에서 아래를 입력하세요.

```
/plugin marketplace add multica-ai/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills

/plugin marketplace add bradautomates/claude-video
/plugin install watch@claude-video

/plugin marketplace add obra/superpowers
/plugin install superpowers@superpowers-dev

/plugin marketplace add Lum1104/Understand-Anything
/plugin install understand-anything@understand-anything

/plugin marketplace add rohitg00/agentmemory
/plugin install agentmemory@agentmemory
```

---

## 설치 후 — 일부 스킬은 추가 도구가 필요해요

| 스킬 | 추가로 필요한 것 |
|---|---|
| `watch` (영상 보기) | `yt-dlp` + `ffmpeg` |
| `understand-*` (코드 이해) | npm/pnpm으로 CLI 빌드 |
| `agentmemory` (기억) | MCP 서버 설치 + 연결 |

나머지 스킬(Karpathy, Superpowers 등)은 추가 도구 없이 바로 작동합니다.

---

## 어떤 방법이 나에게 맞나?

- **빠르게, 그대로 복제** → 방법 A
- **나중에 업데이트/삭제를 깔끔히 관리** → 방법 B
- **이 저장소에서만** 쓸 거면 → 이미 `.claude/skills/`에 들어 있으니 저장소만 열면 됩니다
