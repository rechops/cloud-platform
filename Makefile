APPS=dev-support
DOCKER_TARGETS=$(addsuffix .docker, $(APPS))

%.docker:
	$(eval IMAGE_NAME = $(subst -,_,$*))
	cd docker/$* && docker build -t $(IMAGE_NAME) .

docker: $(DOCKER_TARGETS)

%.infra:
	cd terraform/$* && terraform init && terraform apply -auto-approve

%.deinfra: 
	cd terraform/$* && terraform init && terraform destroy -auto-approve

%.plan:
	cd terraform/$* && terraform init && terraform plan

create.platform:
	$(MAKE) backend-support.infra
	$(MAKE) base.infra

destroy.platform:
	$(MAKE) base.deinfra
	$(MAKE) backend-support.deinfra