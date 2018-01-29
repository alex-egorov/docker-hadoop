default: docker_build

DOCKER_IMAGE ?= alex202/hadoop
TEST_COMMAND ?=

GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

ifeq ($(GIT_BRANCH), master)
	DOCKER_TAG = latest
else
	DOCKER_TAG = $(GIT_BRANCH)
endif

# For debug. Usage: make print-VARIABLE
print-%  : ; @echo $* = $($*)

all: docker_build docker_test docker_push

docker_build:
	docker build \
	  --build-arg VCS_REF=$$(git rev-parse --short HEAD) \
	  --build-arg BUILD_DATE=$$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
	  -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

docker_test:
	#docker run -d -p 50075:50075 -e NAMENODE=masternode --hostname masternode --name hadoop_test $(DOCKER_IMAGE):$(DOCKER_TAG) $(TEST_COMMAND)
	#sleep 30
	#curl -L http://127.0.0.1:50075/
	#docker rm -f hadoop_test
