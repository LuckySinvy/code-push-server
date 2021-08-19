ROOT := $(shell pwd)
VERSION := $(shell node -p "require('./package.json').version")

.PHONY: test
test: test-integration

# test-unit:
# 	@echo "\nRunning unit tests..."
# 	@NODE_ENV=test CONFIG_FILE=${ROOT}/config/config.test.js mocha test/unit --recursive

.PHONY: test-integration
test-integration:
	@echo "\nRunning integration tests..."
	@CONFIG_FILE=${ROOT}/config/config.js mocha test/api/init
	@PORT=3000 HOST=127.0.0.1 CONFIG_FILE=${ROOT}/config/config.js node bin/www &
	@CONFIG_FILE=${ROOT}/config/config.js mocha \
	test/api/users test/api/auth test/api/account test/api/accessKeys test/api/apps test/api/index --recursive --timeout 15000

.PHONY: coverage
coverage:
	@echo "\n\nRunning coverage report..."
	rm -rf coverage
	@CONFIG_FILE=${ROOT}/config/config.js mocha test/api/init
	@PORT=3000 HOST=127.0.0.1 CONFIG_FILE=${ROOT}/config/config.js node bin/www &
	@CONFIG_FILE=${ROOT}/config/config.js ./node_modules/istanbul/lib/cli.js cover --report lcovonly --dir coverage/api ./node_modules/.bin/_mocha \
	test/api/users test/api/auth test/api/account test/api/accessKeys test/api/apps test/api/index -- -R spec --recursive --timeout 15000
	@CONFIG_FILE=${ROOT}/config/config.js ./node_modules/istanbul/lib/cli.js report

.PHONY: build-docker
build-docker:
	@echo "\nBuilding docker image..."
	docker pull node:lts-alpine
	docker build -t shmopen/code-push-server:latest .
	docker tag shmopen/code-push-server:latest shmopen/code-push-server:${VERSION}
	docker push shmopen/code-push-server:${VERSION}
	docker push shmopen/code-push-server:latest