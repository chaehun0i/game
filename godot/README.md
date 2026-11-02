# 해온동 PC 게임

Godot 4 기반 2D 생활·사회 시뮬레이션입니다. 열 명의 이웃은 각자 일정과 목표를 따라 생활하고, 플레이어의 선택을 기억하며 관계를 이어 갑니다. 외부 AI 서비스가 없어도 규칙 기반 대화와 세계 시뮬레이션으로 플레이할 수 있습니다.

## 실행

저장소 루트에서 다음 명령으로 실행합니다.

```powershell
& ".\godot\.tools\Godot_v4.7.2-stable_win64.exe" --path ".\godot"
```

Godot 에디터에서는 **프로젝트 실행(F6가 아닌 F5)** 으로 게임을 시작합니다. `tests/pc_smoke.gd`는 게임이 아니라 검증 스크립트이므로 에디터에서 직접 실행하지 않습니다.

## 조작

- `WASD` 또는 방향키: 이동
- 마우스 클릭: 지점·주민·건물로 이동
- `E`: 가까운 주민과 대화하거나 장소/실내 물건 살펴보기
- `I`: 가방
- `C`: 내 정보
- `N`: 이웃 기록
- `Esc`: 창 닫기 또는 일시정지
- `F1`: 도움말

건물 입구로 걸어가면 내부 장면으로 들어갑니다. 실내에서는 가구와 물건에 다가가 `E`를 누르고, 문 쪽으로 이동해 밖으로 나옵니다.

일부 발견은 한 번 눌러서 얻는 보상이 아닙니다. 여러 날에 걸친 생활 습관과 맞는 장소, 그곳에 있는 이웃이 맞물리면 특별한 물건이나 동네 사건이 열립니다. 진행 상황과 발견물은 저장되어 나중에 이어갈 수 있습니다.

## 자연어 대화

Ollama가 없어도 대화창에 문장을 입력할 수 있습니다. 기본 게임 규칙이 지원하는 의도를 처리하고, 나머지는 주민의 성격과 상황에 맞춘 안전한 답변으로 이어집니다.

### Ollama 로컬 대화 (선택)

1. [Ollama for Windows](https://ollama.com/download/windows)를 설치하고 실행합니다.
2. PowerShell에서 기본 모델을 내려받습니다.

   ```powershell
   ollama run gemma3:1b
   ```

3. Ollama가 `127.0.0.1:11434`에서 실행 중일 때 게임을 시작합니다.

모델을 자동으로 내려받지 않습니다. 연결 실패 시 기본 대화로 돌아갑니다. 로컬 모델에 보내는 문맥에는 공개된 주민 성격·가치관·목표와 플레이어에게 알려진 최근 기억을 사용하며, 아직 공유되지 않은 고민은 제외합니다. 모델 응답 자체는 관계·기억·약속·경제 상태를 바꾸지 않습니다.

## 구조

- `scripts/main.gd`: 세계 진행과 입력 흐름 조정
- `scripts/player.gd`: 플레이어 이동 및 표현
- `scripts/resident.gd`: 주민 개별 상태와 표현
- `scripts/interior_catalog.gd`: 건물 내부 배치 및 상호작용 위치 데이터
- `scripts/interior_view.gd`: 실내 렌더링
- `scripts/main.gd`: NPC 사이 대화 장면의 생성, 현장 참여·경청·지나치기 처리
- `scripts/jev_choice_provider.gd`: 선택적 사회 장면 결정 연결
- `scripts/ollama_dialogue_provider.gd`: 선택적 로컬 대화 연결

## 확인

PC 흐름 스모크 테스트:

```powershell
& ".\godot\.tools\Godot_v4.7.2-stable_win64_console.exe" --headless --path ".\godot" --script res://tests/pc_smoke_runner.gd
```

개별 테스트 스크립트는 프로젝트 루트가 아니라 해당 테스트 실행기에서 시작합니다. `pc_smoke_runner.gd`가 내부에서 PC 흐름 테스트를 불러옵니다.

실내 상호작용 스모크 테스트:

```powershell
godot --headless --path godot --script res://tests/interior_smoke.gd
```

각 건물의 전용 실내 배경은 `assets/interiors/` 아래에 PNG 한 장씩 저장되어 있습니다. 잘라 쓰는 아틀라스가 아니며, 내부 화면은 해당 장소 그림과 그 장소의 상호작용 위치 데이터를 함께 사용합니다. 배경은 320×180 픽셀 그리드에서 색 단계를 정리한 뒤 960×540으로 최근접 확대해 캐릭터의 픽셀 감도와 맞췄습니다.

배경 원본을 다시 준비할 때는 다음 도구를 실행합니다.

```powershell
& ".\godot\.tools\Godot_v4.7.2-stable_win64_console.exe" --headless --path ".\godot" --script res://tools/prepare_interior_pixel_art.gd
```

NPC 사이 대화 장면 검증:

```powershell
godot --headless --path godot --script res://tests/social_scene_smoke.gd
```

Godot 에디터에서 장면과 입력을 수정한 경우 저장소 루트의 `AGENTS.md`가 요구하는 최소 검증을 함께 실행합니다.
