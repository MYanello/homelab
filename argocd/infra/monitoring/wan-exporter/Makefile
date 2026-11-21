REGISTRY := harbor.yanello.net/library
VERSION  := v0.4.10
PLATFORM := linux/amd64
IMAGE := wan-exporter
.PHONY: build

build:
	docker buildx build -f Containerfile --push --platform $(PLATFORM) \
	-t $(REGISTRY)/nix-cache:$(VERSION) -t $(REGISTRY)/$(IMAGE):latest $(PUSH) .
