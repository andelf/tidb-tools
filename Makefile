

LDFLAGS += -X "main.Version=1.0.0~rc2+git.$(shell git rev-parse --short HEAD)"
LDFLAGS += -X "main.BuildTS=$(shell date -u '+%Y-%m-%d %I:%M:%S')"
LDFLAGS += -X "main.GitHash=$(shell git rev-parse HEAD)"

GO := GO15VENDOREXPERIMENT=1 go

PACKAGES := $$(go list ./...| grep -vE 'vendor')
PACKAGE_DIRS := ./importer ./syncer ./checker ./loader ./dump_region

.PHONY: build importer syncer checker loader test check deps

build: importer syncer checker loader check test

importer:
	$(GO) build -o bin/importer ./importer

syncer:
	$(GO) build -ldflags '$(LDFLAGS)' -o bin/syncer ./syncer

checker:
	$(GO) build -o bin/checker ./checker

loader:
	$(GO) build -o bin/loader ./loader

dump_region:
	$(GO) build -o bin/dump_region ./dump_region

test:
	$(GO) test -cover $(PACKAGES)

check:
	@ $(GO) get github.com/golang/lint/golint

	$(GO) tool vet $(PACKAGE_DIRS)
	$(GO) tool vet --shadow $(PACKAGE_DIRS)
	golint $(PACKAGES)
	gofmt -s -l $(PACKAGE_DIRS)

update:
	which glide >/dev/null || curl https://glide.sh/get | sh
	which glide-vc || go get -u github.com/sgotti/glide-vc
ifdef PKG
	glide get -s -v --skip-test ${PKG}
else
	glide update -s -v -u --skip-test
endif
	@echo "removing test files"
	glide vc --only-code --no-tests
