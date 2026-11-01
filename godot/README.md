# 해온동 PC 게임

Godot 4로 실행하는 해온동 생활·사회 시뮬레이션입니다. 기본 대화는 외부 네트워크 없이 동작하며, Gemini API를 설정하면 입력한 문장에 맞춘 주민 대화를 사용할 수 있습니다.

## 실행

저장소 루트에서 다음 명령으로 실행합니다.

```powershell
& ".\godot\.tools\Godot_v4.7.2-stable_win64.exe" --path ".\godot"
```

## 자연어 대화

API 키가 없어도 대화창의 입력란에 문장을 쓸 수 있습니다. 인사, 취향, 동네 소식, 약속, 중재와 관련된 표현은 게임 규칙으로 처리하고, 그 외 문장에는 주민의 취향을 반영한 기본 답변을 보여줍니다.

개발 중 Gemini 대화를 시험하려면 PowerShell에서 현재 실행 세션에만 환경 변수를 설정한 뒤 실행합니다.

```powershell
$env:HAEONDONG_GEMINI_ENABLED = "1"
$env:GEMINI_API_KEY = "여기에_개인_API_키"
& ".\godot\.tools\Godot_v4.7.2-stable_win64.exe" --path ".\godot"
```

원하면 모델을 바꿀 수 있습니다.

```powershell
$env:HAEONDONG_GEMINI_MODEL = "gemini-3.8-flash"
```

Gemini를 켜면 입력 문장과 주민의 공개 프로필 일부가 답변 생성을 위해 Google로 전송됩니다. 비공개 고민과 게임 내부 기억은 전송하지 않습니다. 키가 없거나 네트워크 요청이 실패하면 기본 대화로 돌아갑니다.

**이 직접 연결 방식은 개발자의 로컬 시험용입니다.** 배포된 게임에는 API 키가 노출될 수 있으므로 넣지 마세요. 외부 배포 전에는 키를 서버에 보관하는 프록시를 마련해야 합니다. 키는 저장소에 기록하거나 커밋하지 마세요.
