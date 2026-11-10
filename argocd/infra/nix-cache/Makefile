REGISTRY := harbor.yanello.net/library
VERSION  := v3.3.0-2
PLATFORM := linux/amd64

.PHONY: build 

build:
	docker buildx build -f Containerfile --push --platform $(PLATFORM) \
		-t $(REGISTRY)/nix-cache:$(VERSION) -t $(REGISTRY)/nix-cache:latest $(PUSH) .
