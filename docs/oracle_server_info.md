# Oracle Cloud 서버 정보

> today.bike 프로덕션 서버 — Oracle Cloud Always Free Tier

---

## 서버 스펙

| 항목 | 값 |
|------|-----|
| Provider | Oracle Cloud Infrastructure (OCI) |
| Region | Japan Central (Osaka) `ap-osaka-1` |
| Availability Domain | `kWNa:AP-OSAKA-1-AD-1` |
| Fault Domain | `FAULT-DOMAIN-2` |
| Instance Name | `today-bike-prod` |
| Instance OCID | `ocid1.instance.oc1.ap-osaka-1.anvwsljrm6eucnycygyfjuiw7bqhq4qomdbm6ngtok3xfgyqmrcu4tnvi5wa` |
| Shape | VM.Standard.E2.1.Micro (Always Free) |
| CPU | 1 OCPU / 2 vCPU — AMD EPYC 7551 2.0GHz |
| RAM | 1GB |
| Swap | 2GB (`/swapfile`) |
| Disk | 45GB (Boot Volume) |
| 요금 | **무료** (Always Free Tier) |

## 네트워크

| 항목 | 값 |
|------|-----|
| Public IP | `217.142.238.243` |
| Private IP | `10.0.0.52` |
| VCN | `geunyunpark-vcn` (`10.0.0.0/16`) |
| Subnet OCID | `ocid1.subnet.oc1.ap-osaka-1.aaaaaaaa5uk3nuu6aaoslm5rkhmfzemfofzbxiozsfdm2yiyljwyeggkbpqa` |

## OS & 소프트웨어

| 항목 | 버전 |
|------|------|
| OS | Ubuntu 24.04.4 LTS (Noble Numbat) |
| Kernel | 6.17.0-1007-oracle |
| Docker | 28.2.2 |
| Docker Compose | 2.37.1 |

## SSH 접속

```bash
ssh ubuntu@217.142.238.243
```

- 키: `~/.ssh/id_ed25519` (로컬 Mac 기본 키)
- 사용자: `ubuntu`

## 현재 배포 경로

현재 프로덕션 배포는 Kamal이 아니라 수동 GHCR + SSH 경로를 사용한다.

- 실행 스크립트: `bin/deploy`
- 배포 대상 컨테이너: `today-bike`
- 배포 이미지: `ghcr.io/cyanluna-git/today-bike:latest`
- 영속 볼륨: `today-bike_storage:/rails/storage`

요약 흐름:

```text
로컬 working tree
  -> docker build
  -> GHCR push
  -> Oracle VM SSH 접속
  -> docker pull / stop / rm / run
  -> HTTP 200 헬스체크
```

배포 런북:

- `docs/current_deploy_runbook.md`

## 방화벽 (iptables)

```
1  ACCEPT  state RELATED,ESTABLISHED
2  ACCEPT  icmp
3  ACCEPT  loopback
4  ACCEPT  tcp dpt:22   (SSH)
5  ACCEPT  tcp dpt:443  (HTTPS)
6  ACCEPT  tcp dpt:80   (HTTP)
7  REJECT  all          (나머지 차단)
```

규칙은 `netfilter-persistent`로 영구 저장됨.

> OCI Security List에서도 동일 포트가 열려 있어야 함:
> Networking → VCN → Subnet → Security List → Ingress Rules

## OCI 계정 정보

| 항목 | 값 |
|------|-----|
| Tenancy OCID | `ocid1.tenancy.oc1..aaaaaaaat7jksst3l6butmxhrsdekrepk72twqejq4kh2a4lepmuvsuqxata` |
| User | `geunyun.park@gmail.com` |
| Console | https://cloud.oracle.com |
| Image | Canonical-Ubuntu-24.04-2026.02.28-0 |
| Image OCID | `ocid1.image.oc1.ap-osaka-1.aaaaaaaa4icwwnrg4k7q6qbgwb7ojjnom23tsotvwg6yycwkwjsixf7hwndq` |

## Always Free 한도

| 리소스 | 무료 한도 | 현재 사용 |
|--------|-----------|-----------|
| AMD VM (E2.1.Micro) | 2개 | 1개 |
| ARM VM (A1.Flex) | 4 OCPU + 24GB | 미사용 (Out of capacity) |
| Boot Volume | 200GB 합계 | 45GB |
| Object Storage | 20GB | 미사용 |
| Outbound 트래픽 | 10TB/월 | — |

## 주의사항

- **Public IP는 Reserved가 아님** — 인스턴스 재시작 시 IP가 변경될 수 있음. 변경 시 Cloudflare DNS 업데이트 필요.
- **RAM 1GB** — Rails + Docker 운영 시 swap에 의존하게 됨. 가능하면 나중에 ARM A1 인스턴스(24GB)로 마이그레이션 권장.
- **OCI Security List** — VM 내부 iptables와 별개로 OCI 네트워크 레벨에서도 포트를 열어야 트래픽이 통과함.

## Cloud Shell 참고 명령어

```bash
# Cloud Shell 환경변수
echo $OCI_TENANCY

# 인스턴스 목록
oci compute instance list --compartment-id $OCI_TENANCY --query 'data[?"lifecycle-state"==`RUNNING`].{name:"display-name",id:id,ip:"metadata"}' --output table

# 인스턴스 Public IP 확인
NEW_ID=$(oci compute instance list --compartment-id $OCI_TENANCY --query 'data[?"lifecycle-state"==`RUNNING`].id | [0]' --raw-output)
oci compute instance list-vnics --instance-id "$NEW_ID" --query 'data[0]."public-ip"' --raw-output
```
