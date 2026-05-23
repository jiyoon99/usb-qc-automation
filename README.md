# USB QC Automation

Windows 배치 파일 기반의 USB/하드웨어 출고 전 QC 자동 점검 매크로입니다.

USB 인식, 시스템 도구 실행, C 드라이브 확장 상태, Bluetooth, 배터리, 시간 동기화, 카메라, 사운드, RAM/CPU/GPU 정보를 한 터미널 화면에서 점검하고 최종 상태를 확인할 수 있도록 만든 업무 자동화 스크립트입니다.

## What This Project Shows

- 출고 전 QC 체크리스트를 터미널 기반 실행 흐름으로 자동화
- Batch와 PowerShell 명령을 조합해 Windows 장비 상태를 빠르게 확인
- 일반 장비와 렌탈 장비의 점검 기준을 별도 스크립트로 분리
- 공개용 저장소에서 운영 식별 문자열과 실제 점검 정보를 제거한 정리 방식

## Project Summary

| Item | Description |
| --- | --- |
| Type | Windows batch QC automation |
| Role | 개인 업무 자동화 프로젝트 / 배치 스크립트 구현, 터미널 UI 구성 |
| Goal | 출고 전 USB 및 하드웨어 상태 점검 절차 자동화 |
| Platform | Windows |
| Runtime | Batch, PowerShell commands |
| UI | Terminal dashboard |

## Included Scripts

| Script | Purpose |
| --- | --- |
| `usb-qc-auto-check.bat` | 일반 QC 점검용 스크립트 |
| `rental-usb-qc-auto-check.bat` | 렌탈 장비 QC 점검용 스크립트 |

## Key Features

- 터미널 대시보드 형태의 QC 진행 화면
- USB 드라이브 탐지
- Windows 시스템 도구 실행
- C 드라이브 확장 상태 확인
- Bluetooth 상태 확인
- 배터리 상태, 효율, 사이클, 충전 상태 확인
- 시간 동기화 확인
- 카메라와 사운드 테스트 실행
- RAM, CPU, GPU 정보 표시
- 최종 리포트 화면
- UEFI BIOS 재부팅 옵션 제공

## Preview

![USB QC terminal dashboard preview](docs/assets/usb-qc-dashboard-preview.svg)

> 공개 저장소용 샘플 화면입니다. 실제 장비명, 점검 로그, 운영 식별 정보는 포함하지 않았습니다.

## Why I Built This

장비 출고 전 검수에서는 USB 인식, 드라이브 상태, 배터리 상태, Bluetooth, 카메라, 사운드, 시스템 정보 확인을 반복적으로 수행해야 합니다. 이 스크립트는 여러 확인 절차를 한 터미널 흐름으로 묶어 작업자가 빠르게 점검하고 결과를 확인할 수 있도록 만들었습니다.

렌탈 장비는 일반 출고 장비와 점검 기준이 조금 달라 별도 스크립트로 분리했습니다.

## Run

일반 QC:

```bat
usb-qc-auto-check.bat
```

렌탈 QC:

```bat
rental-usb-qc-auto-check.bat
```

미리보기:

```bat
usb-qc-auto-check.bat --preview
usb-qc-auto-check.bat --preview-final
```

## Safety Notes

- 스크립트 마지막에는 작업자 선택에 따라 `shutdown /r /fw /t 0` 명령으로 UEFI BIOS 재부팅을 실행할 수 있습니다.
- 실제 장비에서 실행하기 전에 스크립트 내용을 확인하는 것이 좋습니다.
- 공개용 저장소에서는 원본 파일명의 작성자/브랜드 식별 문자열을 일반화했습니다.
- 비밀번호, API 토큰, 네트워크 공유 계정 정보는 포함하지 않습니다.

## Project Structure

```text
usb-qc-automation/
├── usb-qc-auto-check.bat
├── rental-usb-qc-auto-check.bat
├── README.md
└── .gitignore
```

## Engineering Notes

- 작업자가 여러 Windows 도구를 따로 열지 않아도 되도록 확인 순서를 하나의 터미널 흐름으로 묶었습니다.
- 장비 유형별 점검 차이를 별도 스크립트로 나누어 유지보수 범위를 줄였습니다.
- BIOS 재부팅처럼 영향이 큰 동작은 작업자 선택 후 실행되도록 분리했습니다.
