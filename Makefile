
IMAGE_NAME=paulb314/ha-operator-test
IMAGE_TAG=latest
nbInstances=6
nbReplicasPerInstance=3

PROMETHEUS_CHART_VERSION=19.2.2
PROMETHEUS_CHART_NAME=prometheus
PROMETHEUS_VALUES_FILE=./values/prometheus.yaml

FAKE_APP_BOOT_TIME=40

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
	@./install.sh $(nbInstances) $(nbReplicasPerInstance) $(FAKE_APP_BOOT_TIME)
.PHONY: install

uninstall:
	@./uninstall.sh $(nbInstances)
.PHONY: uninstall

prometheus:
	@helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	@helm repo update
	@helm install prometheus prometheus-community/prometheus --version 19.2.2
.PHONY: prometheus

grafana:
	@helm repo add grafana https://grafana.github.io/helm-charts
	@helm install grafana grafana/grafana --version 6.49.0
.PHONY: grafana

kind:
	@kind delete cluster --name ha-cluster
	@kind create cluster --config kind.yaml
.PHONY: kind