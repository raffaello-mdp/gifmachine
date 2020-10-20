.PHONY: up
up:
	docker-compose up --build

.PHONY: down
down:
	docker-compose down -v

.PHONY: test
test:
	cd tests && \
	npm i && \
	npm run test
