.PHONY: project
project:
	swift run xcodegen

.PHONY: start
start:
	marathon run ./tools/start.swift

.PHONY: new-module
new-module:
	marathon run ./tools/new-module.swift
