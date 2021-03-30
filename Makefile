NAME                  = my-workshop
CONTAINER_REGISTRY    = my.registry.to.push.to.com
CONTAINER_REPOSITORY  = ${NAME}
version               = latest

# Put it first so that "make" without argument is like "make help".
run: build kind-start educates-deploy

reload: build educates-deploy educates-refresh

refresh: build educates-refresh

.PHONY: build kind-start kind-stop

kind-start:
	deploy/environment/kind/start.sh ${NAME}

kind-stop:
	deploy/environment/kind/stop.sh ${NAME}

educates-deploy:
	deploy/platform/educates/deploy.sh installEducates ${NAME}
	deploy/platform/educates/deploy.sh loadWorkshop ${NAME}

educates-refresh:
	deploy/platform/educates/deploy.sh loadContent ${NAME}

build:
	docker build -t ${CONTAINER_REPOSITORY}:${version} .
	rm -rf build
	mkdir -p build
	docker create --name ${NAME}-build ${CONTAINER_REPOSITORY}:${version}
	docker cp ${NAME}-build:/usr/share/nginx/html/. build/
	docker rm ${NAME}-build

get-reporeg:
	@echo "${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}"

get-name:
	@echo "${NAME}"