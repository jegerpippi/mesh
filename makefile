ALL_ARCHS=amd64
ALL_OS=linux windows macos
ALL_PLATFORMS=linux-amd64 windows-amd64 macos-amd64
ALL_EXE=mesh meshctl mesh_ui

OUT_DIR=built

PATH:=/devroot/toolchain/x86_64-w64-mingw32-seh-cpp20/bin:$(PATH)
PKGVERSION:=$(shell sh contrib/msi/msversion.sh --bare)

take=$(word $1,$(subst -, ,$2))

all: $(ALL_PLATFORMS)

$(addprefix $(OUT_DIR)/,$(ALL_PLATFORMS)):
		mkdir -p $@


linux-amd64: $(addprefix linux-amd64-,$(ALL_EXE))

windows-amd64: $(addprefix windows-amd64-,$(ALL_EXE))
#windows-amd64-%: BUILD_ENV=CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++

macos-amd64: $(addprefix macos-amd64-,$(ALL_EXE))
macos-amd64-%: BUILD_ENV=GO111MODULE=on

$(foreach platf, $(ALL_PLATFORMS), $(addprefix $(platf)-,$(ALL_EXE))):
		$(MAKE) $(OUT_DIR)/$(call take,1,$@)-$(call take,2,$@)
		GOOS=$(call take,1,$@) GOARCH=$(call take,2,$@) $(BUILD_ENV) ./build -g $(call take,3,$@) -b $(OUT_DIR)/$(call take,1,$@)-$(call take,2,$@)

lint:
		golangci-lint run

gen-swagger:
	swag init -g src/restapi/rest_server.go --ot yaml -o contrib/ui/mesh-ui/ui/doc

gen-ie11:export BROWSERSLIST=ie 11
gen-ie11:
	npx babel --config-file ./babel.config.json contrib/ui/mesh-ui/ui/assets/mesh-ui.js --out-file contrib/ui/mesh-ui/ui/assets/mesh-ui-es5.js

ICO:=$(shell realpath riv.ico)
GO_WINRES=go-winres simply --icon $(ICO) --file-version $(PKGVERSION) --file-description "RiV-mesh (c) service, 2023 RIV CHAIN" \
	--product-version $(PKGVERSION) --product-name "RiV-mesh" --copyright "Copyright (c) 2023, RIV CHAIN"

gen-winres:
	cd cmd/mesh && $(GO_WINRES)
	cd cmd/meshctl && $(GO_WINRES) --manifest cli
	cd contrib/ui/mesh-ui && $(GO_WINRES) --manifest gui

clean:

help:
		@echo "Targets:"
		@echo $(ALL_PLATFORMS)
		@echo $(addprefix linux-amd64-,$(ALL_EXE)) 
		@echo $(addprefix windows-amd64-,$(ALL_EXE))
		@echo $(addprefix macos-amd64-,$(ALL_EXE))
