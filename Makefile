.PHONY: project
project:
	swift run xcodegen

.PHONY: start
start:
	swift run swift-sh ./tools/start.swift

.PHONY: new-module
new-module:
	swift run swift-sh ./tools/new-module.swift
