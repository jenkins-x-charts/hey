CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := hey
OS := $(shell uname)

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass.json)

init:
	helm init --client-only

setup: init
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io 	

build: clean setup
	helm dependency build hey
	helm lint hey

install: clean build
	helm upgrade ${NAME} hey --install

upgrade: clean build
	helm upgrade ${NAME} hey --install

delete:
	helm delete --purge ${NAME} hey

clean:
	rm -rf hey/charts
	rm -rf hey/${NAME}*.tgz
	rm -rf hey/requirements.lock

release: clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" hey/Chart.yaml

else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" hey/Chart.yaml
else
	exit -1
endif
	helm package hey
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(VERSION).tgz" $(CHART_REPO)/api/charts
	rm -rf ${NAME}*.tgz
