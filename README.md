# 해온동

Godot 4로 만드는 2D 생활·사회 시뮬레이션 인디게임입니다. 플레이어가 하루를 보내는 동안 이웃들도 각자의 일정과 관계를 이어 갑니다.

## 실행

Godot 4.7 이상에서 `godot/project.godot`를 열거나 저장소 루트에서 실행합니다.

```powershell
godot --path godot
```

PC용 포터블 바이너리를 `godot/.tools/`에 두었다면:

```powershell
& ".\godot\.tools\Godot_v4.7.2-stable_win64.exe" --path ".\godot"
```

조작 및 로컬 대화 설정은 [Godot 게임 안내](godot/README.md)를 참고하세요.

## 프로젝트 구조

- `godot/scripts/main.gd`: 세계 진행을 조율하고 플레이어 입력을 게임 규칙에 연결합니다.
- `godot/scripts/player.gd`: 플레이어 이동과 캐릭터 표현을 담당합니다.
- `godot/scripts/resident.gd`: 주민 표현 및 개별 상태를 보유합니다.
- `godot/scripts/interior_catalog.gd`: 건물별 실내 배치와 출입·가구 상호작용 위치를 정의합니다.
- `godot/scripts/interior_view.gd`: 실내 장면을 그립니다.
- `godot/scripts/main.gd`: 반복 행동과 장소 방문이 비밀 발견·특별 이벤트로 이어지는 경로도 저장 상태에 기록합니다.
- `godot/scripts/main.gd`: NPC끼리의 저녁 대화 장면을 만들고 플레이어의 참여·경청·지나치기를 처리합니다.
- `godot/scripts/*provider.gd`: 선택적 로컬 AI 연결 계층입니다. 연결할 수 없어도 기본 게임은 규칙 기반으로 동작합니다.
- `godot/tests/`: PC 플레이 흐름 및 장면 검증 스크립트입니다.

## 확인

Godot 실행 파일이 준비되어 있을 때 저장소 루트에서 PC 스모크 테스트를 실행할 수 있습니다.

```powershell
godot --headless --path godot --scene res://tests/pc_smoke.tscn
```

실내 상호작용 검증:

```powershell
godot --headless --path godot --script res://tests/interior_smoke.gd
```

NPC 사회 장면 검증:

```powershell
godot --headless --path godot --script res://tests/social_scene_smoke.gd
```

실제 기기, 장시간 플레이, 외부 플레이테스트 결과는 별도로 실행한 경우에만 보고합니다.
