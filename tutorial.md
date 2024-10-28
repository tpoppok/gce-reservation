# 予約作成ジョブの登録
このチュートリアルは Google Compute Engine の予約作成を Cloud Run jobs のジョブとして実行するためのものです。

## 事前準備
以降の手順を進める前に、実際の環境に合わせて下記の変数を変更する必要があります。

[env-vars.yaml]
* RESERVATION_NAME: 一意な予約名
* NUMBER_OF_VMS: 予約する VM の台数 (default:32)
* ZONE: VM をデプロイするゾーン (default:asia-northeast1-b)
* MACHINE_TYPE: 予約する VM の [マシンタイプ](https://cloud.google.com/compute/docs/machine-resource?hl=ja) (default:a3-megagpu-8g)
* PROJECT_ID: プロジェクト ID (NOT プロジェクト名 or プロジェクト番号)


## 予約作成に使用する環境変数の定義
### 現在のプロジェクト ID の確認
以下のコマンドで現在選択しているプロジェクト ID を確認します。
```bash
gcloud config get project
```
もし `(unset)` という文字列が返った場合は、現在プロジェクトを選択していない状態です。その場合、以下のコマンドでプロジェクトを指定する必要があります。
```bash
gcloud config set project [YOUR_PROJECT_ID]
```

### プロジェクト ID を環境変数に挿入
```bash
export PROJECT_ID=$(gcloud config get project)
```

### リージョンを環境変数に挿入
```bash
export REGION="asia-northeast1"
```

## サービス アカウントの準備
Cloud Run jobs が予約を作成するため、ジョブに割り当てるサービスアカウントを作成し、適切な権限を付与します。

### サービス アカウントの作成
```bash
gcloud iam service-accounts create reservation-creator
```
### サービス アカウントに権限を付与
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:reservation-creator@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/compute.instanceAdmin.v1"
```
## コンテナイメージのビルドとプッシュ
Cloud Run jobs のジョブをコンテナイメージとして作成し、Artifact Registry のイメージリポジトリに Push します。

### リポジトリの作成
```bash
gcloud artifacts repositories create reservations \
--repository-format=docker \
--location=$REGION \
--project=$PROJECT_ID
```

### リポジトリパスを環境変数に挿入
```bash
export REPOSITORY_URL="${REGION}-docker.pkg.dev/$PROJECT_ID/reservations"
```

### コンテナイメージのビルド
```bash
docker build . -t reservation-job
```

### イメージへのタグ付け
```bash
docker tag reservation-job:latest $REPOSITORY_URL/reservation-job:latest
```

### イメージの作成
```bash
docker push $REPOSITORY_URL/reservation-job:latest
```

## Cloud Run ジョブの作成
```bash
gcloud run jobs create reservation-job \
--image $REPOSITORY_URL/reservation-job:latest \
--region=$REGION \
--service-account=reservation-creator@${PROJECT_ID}.iam.gserviceaccount.com \
--env-vars-file=env-vars.yaml \
--project=$PROJECT_ID
```

## ジョブのスケジュール登録
ジョブが登録されただけではジョブは実行されません。指定した時刻に実行するには、 [Cloud Console](https://console.cloud.google.com/run/jobs) からジョブのトリガーを設定します。
