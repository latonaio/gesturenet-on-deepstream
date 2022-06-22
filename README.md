# gesturenet-on-deepstream
gesturenet-on-deepstream は、DeepStream 上で GestureNet の AIモデル を動作させるマイクロサービスです。  

## 動作環境
- NVIDIA 
    - DeepStream
- GestureNet
- Docker
- TensorRT Runtime

## GestureNetについて
GestureNet は、画像内の手のジェスチャーを分類し、カテゴリラベルを返すAIモデルです。

## 動作手順
### Dockerコンテナの起動
Makefile に記載された以下のコマンドにより、GestureNet の Dockerコンテナ を起動します。
```
docker-run: ## docker container の立ち上げ
	docker-compose up -d
```

### ストリーミングの開始
Makefile に記載された以下のコマンドにより、DeepStream 上の GestureNet でストリーミングを開始します。  
```
stream-start: ## ストリーミングを開始する
	xhost +
	docker exec -it gesturenet-camera cp /app/mnt/deepstream-gesture-app /app/src/deepstream_tao_apps/apps/tao_others/deepstream-gesture-app/
	docker exec -it gesturenet-camera cp /app/mnt/gesturenet.engine /app/src/deepstream_tao_apps/models/gesture/gesture.etlt_b8_gpu0_fp16.engine
	docker exec -it gesturenet-camera cp /app/mnt/bodyposenet.engine /app/src/deepstream_tao_apps/models/bodypose2d/model.etlt_b32_gpu0_fp16.engine
	docker exec -it gesturenet-camera cp /app/mnt/gesture_sgie_config.txt /app/src/deepstream_tao_apps/configs/gesture_tao/
	docker exec -it -w /app/src/deepstream_tao_apps/apps/tao_others/deepstream-gesture-app gesturenet-camera \
		./deepstream-gesture-app 3 3 ../../../configs/bodypose2d_tao/sample_bodypose2d_model_config.txt /dev/video0 gesture
```

## 相互依存関係にあるマイクロサービス  
本マイクロサービスを実行するために GestureNet の AIモデルを最適化する手順は、[gesturenet-on-tao-toolkit](https://github.com/latonaio/gesturenet-on-tao-toolkit)を参照してください。  


## engineファイルについて
engineファイルである gesturenet.engine は、[gesturenet-on-tao-toolkit](https://github.com/latonaio/gesturenet-on-tao-toolkit)と共通のファイルであり、当該レポジトリで作成した engineファイルを、本リポジトリで使用しています。

## 演算について
本レポジトリでは、ニューラルネットワークのモデルにおいて、エッジコンピューティング環境での演算スループット効率を高めるため、FP16(半精度浮動小数点)を使用しています。  
浮動小数点値の変更は、Makefileの以下の部分を変更し、engineファイルを生成してください。

```
tao-convert:
	docker exec -it gesturenet-tao-toolkit tao-converter -k nvidia_tlt -p input_1,1x3x160x160,8x3x160x160,8x3x160x160 \
		-t fp16 -d 3,160,160 -e /app/src/gesturenet.engine /app/src/model.etlt
```


