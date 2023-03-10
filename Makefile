BUILD_DIR = build
RED="\\033[91m"
GRE="\\033[92m"
YEL="\\033[93m"
END="\\033[0m"

.DEFAULT_GOAL :=
default: test integ integ-cover

clean: # Clean generated files
	@rm -rf $(BUILD_DIR)

.PHONY: build
build: # Build project
	@echo "$(YEL)Build API$(END)"
	@mkdir -p $(BUILD_DIR)
	@go build -o $(BUILD_DIR) ./...

run: clean build # Run server
	@echo "$(YEL)Run API$(END)"
	@build/go-rest-api

test: # Run unit tests
	@echo "$(YEL)Test API$(END)"
	@mkdir -p $(BUILD_DIR)
	@go test -coverprofile $(BUILD_DIR)/coverage-unit.out $(GOPACKAGE) || (echo "$(RED)ERROR$(END) unit tests failed"; exit 1)
	@go tool cover -html=$(BUILD_DIR)/coverage-unit.out -o $(BUILD_DIR)/coverage-unit.html
	@echo "Unit test coverage report in $$(pwd)/$(BUILD_DIR)/coverage-unit.html"
	@echo "$(GRE)OK$(END) unit tests passed"

integ: clean build # Run integration tests
	@echo "$(YEL)Run API integration tests$(END)"
	@build/go-rest-api & \
		PID=$$!; \
		until curl http://127.0.0.1:8080; do \
			sleep 0.1; \
		done; \
		venom run test.yml; \
		kill $$PID

integ-cover: # Run integration tests with coverage
	@echo "$(YEL)Run API integration tests and generate coverage report$(END)"
	@mkdir -p $(BUILD_DIR)
	@go test -c -o $(BUILD_DIR)/go-rest-api-integ -covermode=set -coverpkg=./... -tags integration .
	@build/go-rest-api-integ -test.coverprofile=$(BUILD_DIR)/coverage-integ.out || (echo "$(RED)ERROR$(END) integration tests failed"; exit 1)
	@go tool cover -html=$(BUILD_DIR)/coverage-integ.out -o $(BUILD_DIR)/coverage-integ.html
	@echo "Integration tests coverage report in $$(pwd)/$(BUILD_DIR)/coverage-integ.html"
	@echo "$(GRE)OK$(END) integration tests success"

venom: # Run integration test with HTTP executor
	@echo "$(YEL)Run API integration tests with HTTP executor$(END)"
	@build/go-rest-api & \
		PID=$$!; \
		until curl http://127.0.0.1:8080; do \
			sleep 0.1; \
		done; \
		venom run venom.yml; \
		kill $$PID

tavern: # Run integration test with Tavern
	@echo "$(YEL)Run API integration tests with Tavern$(END)"
	@build/go-rest-api & \
		PID=$$!; \
		until curl http://127.0.0.1:8080; do \
			sleep 0.1; \
		done; \
		tavern-ci test_api.tavern.yaml; \
		kill $$PID
