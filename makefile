# 默认目标
.PHONY: all
all: build

# 构建目标：仅调用 nimble build
.PHONY: build
build:
	nimble build -y

# 测试目标：先保证构建成功，再运行 nimble test
.PHONY: test
test: build
	nimble test -y

# 清理目标（可选）
.PHONY: clean
clean:
	rm -rf ./bin