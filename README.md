# USB QC Automation

Windows 장비 출고 전 USB, 저장장치, 시스템 사양, Bluetooth, 배터리, 카메라 상태를 순서대로 확인하는 Batch 기반 QC 터미널 대시보드입니다.

![USB QC terminal dashboard preview](docs/assets/usb-qc-dashboard-preview.svg)

## What I Built / 만든 것

여러 Windows 도구와 명령을 따로 실행하던 출고 검수 절차를 하나의 스크립트 흐름으로 묶었습니다. 일반 장비와 렌탈 장비의 절차를 분리하고, 각 단계의 진행 상태와 최종 결과를 터미널 대시보드에 표시합니다.

## Main Features / 주요 기능

- 이동식 드라이브에서 USB 점검 도구 폴더 탐색
- PCI, ACPI, USB, 저장장치 정보 수집
- CPU, RAM, GPU 정보 표시
- C 드라이브 확장 가능 여부 확인 및 선택적 확장
- Bluetooth PnP 장치 상태 확인
- `powercfg /batteryreport` 기반 배터리 효율·사이클·충전 상태 분석
- Windows 카메라 앱과 시스템 점검 도구 실행
- 단계별 상태, 최근 동작, 문제 개수를 대시보드에 표시
- 일반 QC와 렌탈 QC 스크립트 분리
- 검수 종료 후 선택적으로 UEFI BIOS 재부팅

## Development / 개발 방식

Batch가 전체 작업 순서와 화면을 담당하고, 구조화된 시스템 조회는 PowerShell을 호출해 처리합니다.

```text
Batch workflow and dashboard
        ↓
PowerShell WMI/CIM/PnP queries
        ↓
normalized result variables
        ↓
stage status and issue count
        ↓
final QC summary
```

- 반복되는 프레임, 상태 라인, 대시보드 렌더링을 Batch subroutine으로 분리했습니다.
- PowerShell 조회가 실패해도 `UNKNOWN` 또는 실패 상태로 변환해 다음 검사를 계속합니다.
- 장비 유형별 차이는 두 실행 파일로 분리해 검수 순서를 명확하게 유지했습니다.
- `--preview`, `--preview-final` 옵션으로 실제 검사를 수행하지 않고 화면을 확인할 수 있습니다.

## Included Scripts / 포함 스크립트

| 파일 | 역할 |
| --- | --- |
| `usb-qc-auto-check.bat` | 일반 출고 QC |
| `rental-usb-qc-auto-check.bat` | 렌탈 장비 QC |

## Run / 실행

```bat
usb-qc-auto-check.bat
rental-usb-qc-auto-check.bat
```

화면 미리보기:

```bat
usb-qc-auto-check.bat --preview
usb-qc-auto-check.bat --preview-final
```

## Tech Stack / 기술 스택

| 영역 | 기술 |
| --- | --- |
| Workflow | Windows Batch |
| System query | PowerShell, WMI/CIM, PnP cmdlets |
| UI | Terminal dashboard |
| Platform | Windows |

## Safety / 실행 주의

마지막 단계의 `shutdown /r /fw /t 0`은 사용자가 선택했을 때만 UEFI BIOS 재부팅을 실행합니다. 실제 장비에서 실행하기 전에 스크립트와 검수 순서를 확인해야 합니다.

## License

MIT License
