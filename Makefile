#    ed-pilot-check returns last known location of pilot from edsm.net
#    Copyright (C) 2018  Armen Kaleshian
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
VERSION := $(shell git log | head -1 | awk '{print $$2}')

.PHONY: clean build	deploy-static deploy-lambda deploy-stack update-lambda
.PHONY: destroy-stack

clean:
	rm -rf build *.zip

build: clean
	mkdir build
	cp ed-pilot-check.py build
	pip install -r requirements.txt -t build
	cd build && zip -r ../$(VERSION).zip *

deploy-lambda: build
ifdef LAMBDA_BUCKET_NAME
ifdef PREFIX
	aws s3 cp $(VERSION).zip s3://$(LAMBDA_BUCKET_NAME)/$(PREFIX)/
else
	aws s3 cp $(VERSION).zip s3://$(LAMBDA_BUCKET_NAME)/
endif
endif

deploy-stack: deploy-lambda
ifdef CFT_BUCKET_NAME
ifdef PREFIX
	$(eval PARAMETERS='[{"ParameterKey": "edsmapikey", "ParameterValue": "$(EDSM_API_KEY)"}, {"ParameterKey": "bucketname","ParameterValue": "$(LAMBDA_BUCKET_NAME)"}, {"ParameterKey": "codepath", "ParameterValue": "$(PREFIX)/$(VERSION).zip"}]')
	aws s3 cp templates/cft.yaml s3://$(CFT_BUCKET_NAME)/$(PREFIX)/
	aws cloudformation create-stack --stack-name ed-pilot-check \
        --template-url \
        https://s3.amazonaws.com/$(CFT_BUCKET_NAME)/$(PREFIX)/cft.yaml \
        --parameters $(PARAMETERS) \
        --capabilities CAPABILITY_IAM
else
	$(eval PARAMETERS='[{"ParameterKey": "edsmapikey", "ParameterValue": "$(EDSM_API_KEY)"}, {"ParameterKey": "bucketname", "ParameterValue": "$(LAMBDA_BUCKET_NAME)"}, {"ParameterKey": "codepath", "ParameterValue": "$(VERSION).zip"}]')
	aws s3 cp templates/cft.yaml s3://$(CFT_BUCKET_NAME)/
	aws cloudformation create-stack --stack-name ed-pilot-check \
        --template-url \
        https://s3.amazonaws.com/$(CFT_BUCKET_NAME)/cft.yaml \
        --parameters $(PARAMETERS) \
        --capabilities CAPABILITY_IAM
endif
endif

update-lambda: build
ifdef LAMBDA_BUCKET_NAME
ifdef PREFIX
	aws s3 cp $(VERSION).zip s3://$(LAMBDA_BUCKET_NAME)/$(PREFIX)/
	aws lambda update-function-code --function-name edpilotcheck \
                                    --s3-bucket $(LAMBDA_BUCKET_NAME) \
                                    --s3-key $(PREFIX)$/(VERSION).zip
else
	aws s3 cp $(VERSION).zip s3://$(LAMBDA_BUCKET_NAME)/
	aws lambda update-function-code --function-name edpilotcheck \
                                    --s3-bucket $(LAMBDA_BUCKET_NAME) \
                                    --s3-key (VERSION).zip
endif
endif

deploy-static:
ifdef STATIC_BUCKET_NAME
	    aws s3 cp theme/ s3://$(STATIC_BUCKET_NAME)/ --recursive
endif

destroy-stack:
ifdef STACK_NAME
	aws cloudformation delete-stack --stack-name $(STACK_NAME)
endif
