.PHONY: test
test:
	crystal $(shell find test -iname "*_test.cr") -- --verbose
