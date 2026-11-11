# Seam

[English](README.md) | **한국어**

집에 있는 리눅스 기계 여러 대의 홈 폴더를 **한 루트 `#` 아래** 묶어 보여 주는 셸.
진짜 bash 그대로인데, 다른 기계의 파일이 내 폴더처럼 보입니다. 그게 전부입니다.

```
#> ls
#/home/desk  #/home/laptop
#> cp #/home/laptop/photo.jpg #/home/desk/       # 기계 사이 복사
#> vim #/home/laptop/notes.txt                   # 다른 기계 파일 바로 편집
#> cd @/git                                      # git 폴더가 있는 기계로 이동
```

> CPU/GPU 상태 보기(`top`)와 한가한 기계에서 실행(`run`)까지 들어간 버전은 [`full/`](full/) 폴더의 **seam-full** 입니다.

## 필요한 것

- 리눅스 기계 2대 이상 (같은 와이파이/네트워크)
- 각 기계: `bash`(4 이상), `ssh`, `sshfs`
- 다른 기계들: ssh 서버 (`openssh-server`)

| OS | 설치 | 상태 |
|---|---|---|
| Ubuntu / Debian / Mint | `sudo apt install sshfs openssh-server` | 테스트됨 |
| Fedora | `sudo dnf install fuse-sshfs openssh-server` | 미테스트 (될 것으로 예상) |
| Arch | `sudo pacman -S sshfs openssh` | 미테스트 (될 것으로 예상) |
| Windows | WSL2 에 Ubuntu 설치 후 그 안에서 위 방법 | 미테스트 (WSL에서 sshfs 동작 여부 미확인) |
| macOS | - | **지원 안 함**: 기본 bash 3.x, macFUSE 필요, `fusermount` 없음 |

## 설치

Seam을 쓸 **각 기계마다** 한 번:

```
git clone https://github.com/yusobeck/seam.git
cd seam          # 설치 후에도 이 폴더는 지우지 마세요
./install.sh
```

설치하면 `~/.local/bin/seam` 이 생기고, 처음이면 바로 `seam setup` 마법사가 뜹니다.

1. **이 기계 준비** — ssh, sshfs 있는지 확인 (없으면 설치 안내)
2. **이 기계 이름** — 짧게. 예: `desk`, `laptop`
3. **묶을 다른 기계** — 이름과 주소(IP)를 넣으면:
   - ssh 키가 없으면 만들어 주고
   - 그 기계 비밀번호를 **한 번만** 물어본 뒤 키를 등록해서
   - 다음부터는 비밀번호 없이 자동으로 붙습니다
4. **저장** — `~/.config/seam/machines` (직접 고쳐도 됩니다)

이미 `~/.ssh/config`에 Host 이름이 있으면 주소 칸에 그 이름을 넣으면 됩니다.

## 사용

```
seam            # 시작 (나가기: exit, 안에서 help)
seam setup      # 기계 추가/변경
seam doctor     # 연결 상태 점검
```

### 경로

| 쓰는 법 | 뜻 |
|---|---|
| `#` | Seam 맨 위. `cd` 만 치면 여기로 |
| `#/home/laptop/a.txt` | laptop 기계의 `~/a.txt` |
| `@/laptop` | laptop의 홈 (`#/home/laptop` 과 같음) |
| `@/git` | `~/git` 이 있는 기계를 찾아서. 여러 기계에 있으면 후보를 보여 주고 실행 안 함 |

`cd ..` 를 계속해도 `#` 위로는 안 나갑니다.

`ls cat cp mv rm mkdir rmdir touch vim nano less head tail grep find du stat file` 는 `#/` `@/` 경로를 그대로 받습니다.

## 알아 둘 것

- 다른 기계 홈은 **진짜**입니다. `rm` 하면 정말 지워집니다.
- `>` 리다이렉트, 그리고 위 목록에 없는 명령(python 등)은 `#/` 경로를 모릅니다. 그럴 땐 `cd` 로 그 폴더에 들어가서 상대 경로로 쓰세요.
- 다른 기계 홈은 마지막 Seam 창을 닫을 때 연결이 풀립니다.
- 지금은 리눅스끼리만 확인했습니다 (위 표 참고). 새 기계마다 clone 하면 됩니다.

## 파일

```
seam              실행기 (start / setup / doctor)
install.sh        ~/.local/bin/seam 연결 + 첫 설정
linux/common.sh   기계 목록 읽기, ssh 공통
linux/seamrc      Seam 셸 (# @ 경로, cd, ls ...)
full/             seam-full
```

## 라이선스

[MIT](LICENSE)
