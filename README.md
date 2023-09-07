# kubernetes-check-script

kubernetes master node를 점검하는데 활용하기 위한 Shell Script

<br>

## 📕 프로젝트 소개

Kubernetes를 운영중인 환경에서 Master 노드가 정상인지 전체적인 상태를

점검하는 절차를 Shell Script를 사용하여 자동화했습니다.

<br>

## 📌 버전 정보

23.09.07 최초 업로드 (v1.2)

<br>

## 🖥 서버 정보

OS : CentOS 8
Kubernetes Version : v1.19
Container Runtime :  Crio (v1.19)

<br>

## 📃 주요 기능

총 8 Step으로 구성되어 있습니다.

Step1. Control Plane Container Check
- crictl command를 통해 static container들의 Status 조회

Step2. Master Node Health Check
-  Rest API 호출을 통해 각 static pod들의 liveness, readiness 체크

Step3. Master Node Certification Check
- script를 실행하는 Master Node의 Kubernetes 인증서 기간 조회

Step4. Kubelet, Crio, Keepalived Status Check
- Kubelet과 Crio의 상태 조회
- Keepalived가 설치된 환경일 경우 Keepalived 상태 조회

Step5. Node List Check
- Kubernetes Cluster의 Node 구성 정보와 상태 조회

Step6. Pod List Check
- 현재 배포되어 있는 Pod의 총 개수, Running 상태인 Pod의 개수, Running이 아닌 상태의 Pod 개수 및 리스트 조회

Step7. Nginx Resource Check (선택)
- Nginx Controller의 Resource 정보를 확인하기 위해 만든 Step으로 타 클러스터에서 사용시 해당 Step 삭제
- 특정 파드의 Resource 설정을 확인하고 싶으면 해당 Step을 수정하여 사용 가능

Step8. Node Resource Check
- script를 돌리는 Node의 Resource 사용량 조회 ( CPU, Memory, Disk)
- CPU 사용량은 30초 평균 사용량, Disk는 '/' 디렉토리의 사용량(80% 초과시 위험) 확인

