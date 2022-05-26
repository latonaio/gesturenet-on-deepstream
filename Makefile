:# Self-Documented Makefile
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

docker-build: ## docker image の作成
	docker-compose build

docker-run: ## docker container の立ち上げ
	docker-compose up -d

docker-login: ## docker container にログイン
	docker exec -it gesturenet-camera bash

stream-start: ## ストリーミングを開始する
	xhost +
	docker exec -it gesturenet-camera cp /app/mnt/deepstream-gesture-app /app/src/deepstream_tao_apps/apps/tao_others/deepstream-gesture-app/
	docker exec -it gesturenet-camera cp /app/mnt/gesturenet.engine /app/src/deepstream_tao_apps/models/gesture/gesture.etlt_b8_gpu0_fp16.engine
	docker exec -it gesturenet-camera cp /app/mnt/bodyposenet.engine /app/src/deepstream_tao_apps/models/bodypose2d/model.etlt_b32_gpu0_fp16.engine
	docker exec -it gesturenet-camera cp /app/mnt/gesture_sgie_config.txt /app/src/deepstream_tao_apps/configs/gesture_tao/
	docker exec -it -w /app/src/deepstream_tao_apps/apps/tao_others/deepstream-gesture-app gesturenet-camera \
		./deepstream-gesture-app 1 3 ../../../configs/bodypose2d_tao/sample_bodypose2d_model_config.txt /dev/video0 gesture
