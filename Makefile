NAME                  = springone-tour-lab-workshop-2
IMAGE_SOURCE		  = https://github.com/springone-tour-2021/lab-workshop-2
CONTAINER_REGISTRY    = ghcr.io/springone-tour-2021
CONTAINER_REPOSITORY  = ${NAME}
version               = latest

# Put it first so that "make" without argument is like "make help".
run: kind-start educates-deploy reload

reload: build workshop-deploy workshop-deploy workshop-refresh

refresh: build workshop-refresh

start: kind-start workshop-deploy workshop-refresh

stop: kind-stop

delete: kind-delete

clean: kind-clean

.PHONY: build kind-start kind-delete kind-clean kind-stop educates-deploy workshop-deploy workshop-refresh release delete start deploy stop clean get-reporeg get-name

kind-start:
	deploy/environment/kind/deploy.sh start

kind-stop:
	deploy/environment/kind/deploy.sh stop

kind-delete:
	deploy/environment/kind/deploy.sh delete

kind-clean:
	deploy/environment/kind/deploy.sh clean

educates-deploy:
	deploy/platform/educates/deploy.sh installEducates ${NAME}

workshop-deploy:
	deploy/platform/educates/deploy.sh loadWorkshop ${NAME} overlays/kind

workshop-refresh:
	deploy/platform/educates/deploy.sh loadContent ${NAME}

build:
	docker build --build-arg IMAGE_SOURCE=${IMAGE_SOURCE} \
				 -t ${CONTAINER_REPOSITORY}:${version} \
				 -t ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version} .
	rm -rf build
	mkdir -p build
	docker create --name ${NAME}-build ${CONTAINER_REPOSITORY}:${version}
	docker cp ${NAME}-build:/usr/share/nginx/html/. build/
	docker rm ${NAME}-build

release:
	docker push ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version}

deploy:
	docker pull ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version}
	docker tag ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${version} ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${environment}
	docker push ${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:${environment}

get-reporeg:
	@echo "${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}"

get-name:
	@echo "${NAME}"