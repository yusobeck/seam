# Seam (full)

[English](README.md) | **한국어**

> 가볍게 파일만 묶는 버전은 [**seam**](../) 입니다. 이 버전은 거기에 CPU/GPU 상태 보기와 `run`(한가한 기계에서 실행)을 더한 **seam-full** 입니다.

집에 있는 리눅스 기계 여러 대를 **한 루트 `#` 아래** 묶는 셸.
진짜 bash 그대로인데, 다른 기계의 파일이 내 폴더처럼 보이고, 명령은 한가한 기계로 보낼 수 있습니다.

```
#> ls
#/home/desk  #/home/laptop  #/dev
#> cp #/home/laptop/photo.jpg #/home/desk/       # 기계 사이 복사
#> cd @/git                                      # git 폴더가 있는 기계로 이동
#> run make -j4                                  # 가장 한가한 기계에서 빌드
#> run --gpu python train.py                     # GPU 있는 기계에서
#> top                                           # 모든 기계 CPU/RAM/GPU 한눈에
```

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
| macOS | - | **지원 안 함**: 기본 bash 3.x, macFUSE 필요, `/proc`·`lspci`·`fusermount` 없음 |

## 설치

Seam을 쓸 **각 기계마다** 한 번:

```
git clone https://github.com/yusobeck/seam.git
cd seam/full     # 설치 후에도 이 폴더는 지우지 마세요
./install.sh
```

설치하면 `~/.local/bin/seam-full` 이 생기고, 처음이면 바로 `seam-full setup` 마법사가 뜹니다.

1. **이 기계 준비** — ssh, sshfs 있는지 확인 (없으면 설치 안내)
2. **이 기계 이름** — 짧게. 예: `desk`, `laptop`
3. **묶을 다른 기계** — 이름과 주소(IP)를 넣으면:
   - ssh 키가 없으면 만들어 주고
   - 그 기계 비밀번호를 **한 번만** 물어본 뒤 키를 등록해서
   - 다음부터는 비밀번호 없이 자동으로 붙습니다
4. **저장** — `~/.config/seam/machines`

이미 `~/.ssh/config`에 Host 이름이 있으면 주소 칸에 그 이름을 넣으면 됩니다.

## 사용

```
seam-full              # 시작 (나가기: exit, 안에서 help)
seam-full setup        # 기계 추가/변경
seam-full doctor       # 연결 상태 점검
seam-full run ...      # 셸 밖에서 run 한 번 (아래)
```

### 경로

| 쓰는 법 | 뜻 |
|---|---|
| `#` | Seam 맨 위. `cd` 만 치면 여기로 |
| `#/home/laptop/a.txt` | laptop 기계의 `~/a.txt` |
| `@/laptop` | laptop의 홈 (`#/home/laptop` 과 같음) |
| `@/git` | `~/git` 이 있는 기계를 찾아서. 여러 기계에 있으면 후보를 보여 주고 실행 안 함 |
| `#/dev/<기계>/` | 그 기계 정보 파일: `cpu_name` `cpus` `load` `mem_free_mb` `gpu_name` ... |

`cd ..` 를 계속해도 `#` 위로는 안 나갑니다.

`ls cat cp mv rm mkdir vim nano less head tail grep find du stat` 등은 `#/` `@/` 경로를 그대로 받습니다.

### run — 한가한 기계에서 실행

```
run                    # 기계별 CPU/RAM/GPU 사양 + 지금이면 어디로 갈지
run make               # 여유 코어가 가장 많은 기계에서
run --on laptop make   # 기계 지정
run --gpu python t.py  # NVIDIA GPU 있는 기계에서
run -j4 make -j4       # 4코어 여유 있는 기계 우선
run --port 8000 python3 -m http.server 8000
                       # 어디서 돌든 이 기계에서도 localhost:8000 으로 열림
run 'ls | wc -l'       # 파이프 등은 따옴표로
```

`run` 만 치면 이렇게 나옵니다 (예시):

```
  desk (이 기계)
    CPU  Intel Core i5-3450 3.10GHz  4코어 (사용 중 12%, 여유 3.5)
    RAM  15.5GB (여유 10.8GB)
    GPU  NVIDIA GeForce GTX 1050 Ti  (4.0GB, 사용 중 0.5GB, 사용률 3%)
  laptop
    CPU  Intel Core i5 M 450 2.40GHz  4코어 (사용 중 0%, 여유 4.0)
    RAM  7.6GB (여유 6.3GB)
    GPU  AMD Mobility Radeon HD 5430/5450/5470  (계산용 GPU 아님 -> --gpu 불가)
-> 지금 run 하면 laptop 에서 실행됩니다
```

- **기계 고르는 법**: 지금 CPU 사용률(0.4초 동안 직접 측정)로 여유 코어를 계산해서 가장 많은 기계로 보냅니다. 같으면 여유 RAM 이 많은 쪽입니다. 갑자기 바빠진 기계도 바로 반영됩니다.
- **`--gpu`**: NVIDIA GPU(`nvidia-smi`)가 있는 기계만 대상입니다. 바빠도 그 기계로 갑니다.
- 지금 있는 폴더를 따라갑니다. `#/home/desk/git` 에서 laptop 으로 보내면 laptop 의 `~/git` 에서 실행.
- Ctrl-C 로 끊으면 원격 프로세스와 포트 터널도 같이 정리됩니다.
- 명령 종료 코드가 그대로 전달됩니다 (`$?`).

### 셸 밖에서 — seam-full run

스크립트, cron, Claude 같은 곳에서는 Seam 셸을 열 수 없으니 이렇게 씁니다. 옵션은 위 `run` 과 같습니다.

```
seam-full run --gpu python train.py
~/.local/bin/seam-full run --gpu python train.py   # PATH 에 없을 때 (비대화형 ssh 등)
```

이 방식은 sshfs 마운트 없이 ssh 만으로 동작합니다 (`#/` 경로 인자는 마운트가 있을 때만 의미가 있습니다).

## 알아 둘 것

- 다른 기계 홈은 **진짜**입니다. `rm` 하면 정말 지워집니다.
- `>` 리다이렉트, 그리고 위 목록에 없는 명령(python 등)은 `#/` 경로를 모릅니다. 그럴 땐 `cd` 로 그 폴더에 들어가서 상대 경로로 쓰세요.
- 다른 기계 홈은 마지막 Seam 창을 닫을 때 연결이 풀립니다.
- 한 작업을 여러 기계에 나눠 동시에 돌리지는 않습니다 (한 번에 한 기계).
- 일 단위로 보냅니다. 프로그램 전체가 선택된 기계에서 돌고, 다른 기계의 GPU를 원격 장치처럼 직접 쓰지는 않습니다.
- 사용률은 호출한 순간 0.4초 평균이라, 두 기계 여유가 거의 같으면 선택이 달라질 수 있습니다.
- seam 과 seam-full 은 기계 목록(`~/.config/seam/machines`)을 같이 쓰고, 마운트 위치는 따로라 동시에 열어도 됩니다.
- 지금은 리눅스끼리만 확인했습니다 (위 표 참고). 새 기계마다 clone 하면 됩니다.

## 파일

```
seam              실행기 (start / setup / doctor / run)
install.sh        ~/.local/bin/seam-full 연결 + 첫 설정
linux/common.sh   기계 목록 읽기, ssh 공통
linux/seamrc      Seam 셸 (# 경로, cd, top, run ...)
```

## 라이선스

[MIT](../LICENSE)
