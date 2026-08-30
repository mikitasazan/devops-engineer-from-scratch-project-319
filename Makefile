test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew versionCatalogUpdate

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

k8s-apply:
	kubectl apply -f k8s/namespace.yaml -f k8s/configmap.yaml
	kubectl apply -f k8s/secret.example.yaml
	kubectl apply -f k8s/deployment.yaml -f k8s/service.yaml -f k8s/pdb.yaml -f k8s/hpa.yaml

k8s-status:
	kubectl -n bulletin-board get deploy,pods,svc

k8s-port-forward:
	kubectl -n bulletin-board port-forward svc/bulletin-board 8080:8080

helm-lint:
	helm lint k8s/bulletin-board

helm-template:
	helm template bulletin-board k8s/bulletin-board

helm-install:
	helm upgrade --install bulletin-board k8s/bulletin-board --namespace bulletin-board --create-namespace

helm-rollback:
	helm rollback bulletin-board 0 --namespace bulletin-board

.PHONY: build k8s-apply k8s-status k8s-port-forward
