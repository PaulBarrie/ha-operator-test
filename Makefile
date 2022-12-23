
IMAGE_NAME=paulb314/ha-operator-test
IMAGE_TAG=latest
nbInstances=6
nbReplicasPerInstance=3

docker-build:
	@docker build -t $(IMAGE_NAME) api
.PHONY: docker-build

docker-push:
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)
.PHONY: docker-push

deploy:
	$(MAKE) docker-build IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG)
	$(MAKE) docker-push IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG)
.PHONY: deploy

install:
	@./install.sh $(nbInstances) $(nbReplicasPerInstance)
.PHONY: install

uninstall:
	@./uninstall.sh $(nbInstances)
.PHONY: uninstall
