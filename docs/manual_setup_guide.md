# today.bike 수동 설정 가이드

> 코드 작업 전에 사람이 직접 완료해야 하는 외부 서비스 설정 체크리스트입니다.
> 각 서비스에서 API 키/시크릿을 받아오면 나머지 코드 연동은 AI가 처리합니다.

---

## 1. Oracle Cloud VPS 프로비저닝 (Always Free) [#713]

### 현재 상태

| 항목 | 값 |
|------|-----|
| Region | **Japan Central (Osaka)** `ap-osaka-1` |
| Instance | `instance-20260313-1711` |
| Shape | VM.Standard.E2.1.Micro (1 OCPU / 1GB RAM) — Always Free |
| OS | Canonical Ubuntu 24.04 |
| Public IP | `217.142.238.243` (현재 운영 IP, Reserved 아님) |
| Private IP | `10.0.0.52` |
| VCN | `geunyunpark-vcn` |

### 계정 생성 ✅ 완료

1. **Oracle Cloud 가입**: https://cloud.oracle.com/sign-up
   - 신용카드 등록 필요 (과금 안 됨, 본인 확인용)
   - Home Region 선택 시 주의 — 변경 불가

### VM 생성 ✅ 완료

2. **OCI Console 접속**: https://cloud.oracle.com
3. **Compute → Instances → Create Instance**
   - Image: **Canonical Ubuntu 24.04**
   - Shape: **VM.Standard.E2.1.Micro** (AMD x86, 1 OCPU/1GB) — 항상 가용, 2개까지 무료
   - ⚠️ ARM(A1.Flex, 4코어/24GB)은 무료지만 "Out of capacity" 에러가 자주 발생 → 나중에 가용되면 마이그레이션 고려

### VCN + Public IP ✅ 완료

- VCN Wizard로 `geunyunpark-vcn` 생성 (CIDR: `10.0.0.0/16`)
- 현재 운영 Public IP `217.142.238.243` 사용

### SSH 키 등록 (인스턴스 재생성)

> ⚠️ OCI는 이미 생성된 인스턴스에 `ssh_authorized_keys` 메타데이터를 추가할 수 없습니다.
> Cloud Shell도 FIPS 모드라 `ed25519` 키 생성이 불가합니다.
> → **SSH 키 없이 만든 인스턴스는 삭제 후, SSH 키를 포함해서 재생성**해야 합니다.

Cloud Shell에서 순서대로 실행 (`OCI Console 우측 상단 >_ 아이콘`):

**Step 1**: 기존 인스턴스 삭제

```bash
INSTANCE_ID=$(oci compute instance list --compartment-id $OCI_TENANCY --query 'data[0].id' --raw-output)
echo $INSTANCE_ID
oci compute instance terminate --instance-id "$INSTANCE_ID" --preserve-boot-volume false --force
```

삭제 상태 확인 (TERMINATED가 나올 때까지 대기):

```bash
oci compute instance get --instance-id "$INSTANCE_ID" --query 'data."lifecycle-state"' --raw-output
```

**Step 2**: SSH 키 포함해서 새 인스턴스 생성

```bash
oci compute instance launch \
  --compartment-id $OCI_TENANCY \
  --availability-domain "kWNa:AP-OSAKA-1-AD-1" \
  --shape "VM.Standard.E2.1.Micro" \
  --subnet-id "ocid1.subnet.oc1.ap-osaka-1.aaaaaaaa5uk3nuu6aaoslm5rkhmfzemfofzbxiozsfdm2yiyljwyeggkbpqa" \
  --image-id "ocid1.image.oc1.ap-osaka-1.aaaaaaaa4icwwnrg4k7q6qbgwb7ojjnom23tsotvwg6yycwkwjsixf7hwndq" \
  --display-name "today-bike-prod" \
  --assign-public-ip true \
  --metadata '{"ssh_authorized_keys":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKd43jkEnMczSHkzo3Z1/cEs5tdZLOB+OxkFB95qHLx2 cyanluna-pro16@cyanluna-pro16ui-MacBookPro.local"}' \
  --wait-for-state RUNNING
```

> 생성 완료까지 1~2분 소요.

**Step 3**: 새 Public IP 확인

```bash
NEW_ID=$(oci compute instance list --compartment-id $OCI_TENANCY --query 'data[?"lifecycle-state"==`RUNNING`].id | [0]' --raw-output)
oci compute instance list-vnics --instance-id "$NEW_ID" --query 'data[0]."public-ip"' --raw-output
```

> 출력된 IP를 메모. 현재 운영 IP(`217.142.238.243`)와 다를 수 있음 → Cloudflare DNS 업데이트 필요.

**Step 4**: 로컬 Mac 터미널에서 SSH 접속 확인

```bash
ssh ubuntu@{Step3에서_확인한_IP} "echo 'SSH OK' && uname -a"
```

### 네트워크 설정 (Security List)

OCI는 기본적으로 포트가 닫혀 있으므로 수동으로 열어야 합니다:

4. **Networking → Virtual Cloud Networks → `geunyunpark-vcn` → Subnet → Security List**
5. **Ingress Rules 추가**:

| Source CIDR | Protocol | Dest Port | 용도 |
|-------------|----------|-----------|------|
| `0.0.0.0/0` | TCP | 80 | HTTP |
| `0.0.0.0/0` | TCP | 443 | HTTPS |
| `0.0.0.0/0` | TCP | 22 | SSH (기본 존재) |

6. **VM 내부 방화벽도 열기** (SSH 접속 후):

```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save
```

### Always Free 포함 내역

| 항목 | 무료 한도 |
|------|-----------|
| ARM VM (A1.Flex) | 4 OCPU + 24GB RAM (분할 가능) — 가용 시 |
| AMD VM (E2.1.Micro) | 2개 |
| Boot Volume | 200GB 합계 |
| Object Storage | 20GB |
| Outbound 트래픽 | 10TB/월 |

> **주의**: Always Free는 계정이 "Pay As You Go"로 업그레이드되어도 유지됩니다.
> 단, Free 티어 리소스를 초과하는 리소스를 만들면 과금됩니다.

---

## 2. Cloudflare DNS 설정 [#713]

### 도메인 연결

1. **Cloudflare 가입/로그인**: https://dash.cloudflare.com/sign-up
2. **Add a Site** → `today.bike` 입력
3. **플랜 선택**: Free 플랜으로 충분
4. **네임서버 변경**
   - Cloudflare가 안내하는 네임서버 2개를 복사
   - 도메인 등록 업체 (가비아, Namecheap 등)에서 네임서버를 Cloudflare 것으로 변경
   - 반영까지 최대 24시간 (보통 수분~수시간)

### DNS 레코드 추가

Cloudflare Dashboard → DNS → Records:

| Type | Name | Content | Proxy | TTL |
|------|------|---------|-------|-----|
| `A` | `@` | `217.142.238.243` | Proxied (주황색) | Auto |
| `A` | `www` | `217.142.238.243` | Proxied (주황색) | Auto |

> 현재 운영 서버 IP는 Reserved가 아니므로, 인스턴스 재생성/재시작 후 IP가 바뀌면 이 레코드도 같이 갱신해야 합니다.

### SSL 설정

- SSL/TLS → Overview → **Full (strict)** 선택
- Edge Certificates → Always Use HTTPS: **ON**
- Edge Certificates → Automatic HTTPS Rewrites: **ON**

### 메모해둘 것

| 항목 | 값 |
|------|-----|
| Cloudflare Zone ID | Dashboard → Overview 우측 하단 |
| Cloudflare API Token | (R2 설정 시 필요, 아래 참고) |

---

## 3. Cloudflare R2 버킷 (Litestream 백업) [#715]

### 버킷 생성

1. **R2 활성화**: https://dash.cloudflare.com → R2 Object Storage
   - 결제 수단 등록 필요 (무료 티어: 10GB 저장, 월 1천만 읽기)
2. **Create Bucket**
   - 이름: `today-bike-backup`
   - Location: **Automatic** 또는 **EU (WEUR)**

### API 토큰 발급

1. R2 → Overview → **Manage R2 API Tokens**
2. **Create API Token**
   - 권한: **Object Read & Write**
   - 범위: `today-bike-backup` 버킷만
3. 생성 완료 후 표시되는 값을 즉시 복사 (다시 볼 수 없음)

### 메모해둘 것

| 항목 | 용도 |
|------|------|
| R2 Account ID | Litestream 설정 |
| R2 Access Key ID | Litestream 설정 |
| R2 Secret Access Key | Litestream 설정 |
| R2 Endpoint URL | `https://{account-id}.r2.cloudflarestorage.com` |
| Bucket Name | `today-bike-backup` |

---

## 현재 배포 경로 메모

현재 프로덕션 배포는 Kamal이 아니라 `bin/deploy`를 사용하는 수동 GHCR + SSH 경로입니다.

요약:

```text
로컬 working tree
  -> docker build
  -> GHCR push
  -> Oracle VM SSH 접속
  -> docker pull / docker run
  -> HTTP 200 헬스체크
```

실행 전제조건:

- 로컬 `config/master.key`
- `GHCR_TOKEN` 환경변수 (`write:packages` 권한 필요)
- Docker 실행 중
- Oracle VM SSH 접속 가능

실행 명령:

```bash
bin/deploy
```

상세 런북:

- `docs/current_deploy_runbook.md`

---

## 4. 카카오 개발자 앱 (OAuth 로그인) [#749]

### 앱 생성

1. **카카오 개발자 로그인**: https://developers.kakao.com
2. **내 애플리케이션** → **애플리케이션 추가하기**
   - 앱 이름: `투데이바이크`
   - 사업자명: (실제 상호)

### 카카오 로그인 활성화

3. **앱 설정** → **카카오 로그인**
   - 활성화 상태: **ON**
4. **Redirect URI 등록**:
   ```
   https://today.bike/portal/auth/kakao/callback
   http://localhost:3000/portal/auth/kakao/callback
   ```

### 동의 항목 설정

5. **카카오 로그인** → **동의항목**
   - 닉네임: **필수 동의**
   - 카카오계정(이메일): **선택 동의** (비즈앱 전환 후 필수 가능)
   - 프로필 사진: **선택 동의**

### 비즈앱 전환 (선택, 이메일 필수 수집 시)

6. **앱 설정** → **비즈니스** → **비즈앱 전환**
   - 사업자등록증 업로드 필요

### 메모해둘 것

앱 설정 → **앱 키** 에서 확인:

| 항목 | 용도 |
|------|------|
| REST API 키 | OmniAuth `client_id` |
| Client Secret | 보안 → Client Secret 발급 → OmniAuth `client_secret` |

> **Client Secret 발급**: 앱 설정 → 보안 → Client Secret → **코드 생성** → 활성화 상태: **사용함**

---

## 5. 토스페이먼츠 결제 연동 [#773]

### 가맹점 등록

1. **개발자센터 가입**: https://developers.tosspayments.com
2. **내 개발정보** 접속 → 테스트 키 즉시 발급됨
   - https://developers.tosspayments.com/my/api-keys

### 테스트 키 확인 (가입 즉시 사용 가능)

| 항목 | 형식 |
|------|------|
| 테스트 Client Key | `test_ck_xxxxxxxxxxxxxxx` |
| 테스트 Secret Key | `test_sk_xxxxxxxxxxxxxxx` |

> 테스트 키로 개발/테스트를 먼저 진행하고, 실결제는 심사 후 라이브 키로 전환합니다.

### 실결제 심사 (나중에)

3. **토스페이먼츠 가맹점 신청**: https://app.tosspayments.com/signup
4. 필요 서류:
   - 사업자등록증
   - 대표자 신분증
   - 통장 사본
5. 심사 기간: **영업일 기준 3~5일**

### 웹훅 설정 (나중에)

- 개발자센터 → Webhook → URL 등록: `https://today.bike/webhooks/tosspayments`

### 메모해둘 것

| 항목 | 용도 |
|------|------|
| Client Key (test) | 프론트엔드 결제위젯 |
| Secret Key (test) | 서버 결제 승인 API |
| Client Key (live) | 실서비스용 (심사 후) |
| Secret Key (live) | 실서비스용 (심사 후) |

---

## 설정 값 반영

위 과정에서 얻은 키/시크릿을 Rails credentials에 저장합니다:

```bash
bin/rails credentials:edit
```

```yaml
# config/credentials.yml.enc (예시 구조)
oracle:
  server_ip: "217.142.238.243"
  region: "ap-osaka-1"

cloudflare:
  zone_id: "xxxxxxxx"
  r2_account_id: "xxxxxxxx"
  r2_access_key_id: "xxxxxxxx"
  r2_secret_access_key: "xxxxxxxx"
  r2_bucket: "today-bike-backup"

kakao:
  client_id: "REST_API_KEY"
  client_secret: "CLIENT_SECRET"

tosspayments:
  client_key: "test_ck_xxxxxxxx"
  secret_key: "test_sk_xxxxxxxx"
```

---

## 작업 순서 요약

```
[1일차] Oracle Cloud VM 생성 + Cloudflare 도메인 연결 + R2 버킷 생성
         └→ 현재는 `bin/deploy` 기준 수동 GHCR + SSH 배포 진행

[1일차] 카카오 개발자 앱 생성 + 키 발급
         └→ 키 받으면 AI가 OmniAuth 연동 코드 작성

[1일차] 토스페이먼츠 가입 + 테스트 키 확인 + 실결제 심사 신청
         └→ 테스트 키로 AI가 결제 연동 개발 시작
         └→ 심사 완료 후 라이브 키 전환
```

> 모든 외부 설정을 하루에 끝낼 수 있습니다.
> 키/시크릿을 전달해주시면 코드 연동을 바로 시작합니다.
