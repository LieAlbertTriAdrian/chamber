# Goals:
# - user can build binaries on their system without having to install special tools
# - user can fork the canonical repo and expect to be able to run CircleCI checks
#
# This makefile is meant for humans

VERSION := $(shell git describe --tags --always --dirty="-dev")
VERSION_NO_V := $(shell git describe --tags --always --dirty="-dev" | sed 's/^v//')
VERSION_MAJOR_MINOR_PATCH := $(shell git describe --tags --always --dirty="-dev" | sed 's/^v\([0-9]*.[0-9]*.[0-9]*\).*/\1/')
VERSION_MAJOR_MINOR := $(shell git describe --tags --always --dirty="-dev" | sed 's/^v\([0-9]*.[0-9]*\).*/\1/')
VERSION_MAJOR := $(shell git describe --tags --always --dirty="-dev" | sed 's/^v\([0-9]*\).*/\1/')
ANALYTICS_WRITE_KEY ?=
LDFLAGS := -ldflags='-X "main.Version=$(VERSION)" -X "main.AnalyticsWriteKey=$(ANALYTICS_WRITE_KEY)"'

test:
	go test -mod=vendor -v ./...

all: dist/chamber-$(VERSION)-darwin-amd64 dist/chamber-$(VERSION)-linux-amd64 dist/chamber-$(VERSION)-windows-amd64.exe

clean:
	rm -rf ./dist

dist/:
	mkdir -p dist

build: chamber

chamber:
	CGO_ENABLED=0 go build -trimpath -mod=vendor $(LDFLAGS) -o $@

dist/chamber-$(VERSION)-darwin-amd64: | dist/
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -mod=vendor $(LDFLAGS) -o $@

linux: dist/chamber-$(VERSION)-linux-amd64
	cp $^ chamber

dist/chamber-$(VERSION)-linux-amd64: | dist/
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -mod=vendor $(LDFLAGS) -o $@

dist/chamber-$(VERSION)-windows-amd64.exe: | dist/
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -mod=vendor $(LDFLAGS) -o $@

.PHONY: clean all linux
