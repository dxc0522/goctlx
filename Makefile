build:
	go build -ldflags="-s -w" goctlx.go
	$(if $(shell command -v upx || which upx), upx goctlx)

mac:
	GOOS=darwin go build -ldflags="-s -w" -o goctlx-darwin goctlx.go
	$(if $(shell command -v upx || which upx), upx goctlx-darwin)

win:
	GOOS=windows go build -ldflags="-s -w" -o goctlx.exe goctlx.go
	$(if $(shell command -v upx || which upx), upx goctlx.exe)

linux:
	GOOS=linux go build -ldflags="-s -w" -o goctlx-linux goctlx.go
	$(if $(shell command -v upx || which upx), upx goctl-linux)

image:
	docker build --rm --platform linux/amd64 -t kevinwan/goctl:$(version) .
	docker tag kevinwan/goctl:$(version) kevinwan/goctl:latest
	docker push kevinwan/goctl:$(version)
	docker push kevinwan/goctl:latest
	docker build --rm --platform linux/arm64 -t kevinwan/goctl:$(version)-arm64 .
	docker tag kevinwan/goctl:$(version)-arm64 kevinwan/goctl:latest-arm64
	docker push kevinwan/goctl:$(version)-arm64
	docker push kevinwan/goctl:latest-arm64
