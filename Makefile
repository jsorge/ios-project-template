.PHONY: project
project:
	@chmod +x ./tools/ensure-xcodegen.sh
	@./tools/ensure-xcodegen.sh
	@./vendor/XcodeGen

.PHONY: start
start:
	@chmod +x ./tools/ensure-swift-sh.sh
	@./tools/ensure-swift-sh.sh
	@./vendor/swift-sh ./tools/start.swift

.PHONY: new-module
new-module:
	@chmod +x ./tools/ensure-swift-sh.sh
	@./tools/ensure-swift-sh.sh
	@./vendor/swift-sh ./tools/new-module.swift
