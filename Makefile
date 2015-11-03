APACHE_BASE_PATH ?= /$(shell id -un)
APACHE_BASE_DIRECTORY ?= $(CURDIR)
MODWSGI_USER ?= $(shell id -un)
API_URL ?= http://api3.geo.admin.ch
PYTHONVENV_OPTS ?= --system-site-packages


## Python interpreter can't have space in path name
## So prepend all python scripts with python cmd
## See: https://bugs.launchpad.net/virtualenv/+bug/241581/comments/11
PYTHON_CMD=.build-artefacts/python-venv/bin/python

# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))



.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo
	@echo "Possible targets:"
	@echo
	@echo "- all              Install everything"
	@echo "- mapcache         Install and configure mapcache"
	@echo "- config           Configure mapcache (mapcache.yaml)"
	@echo "- clean            Remove generated files"
	@echo "- help             Display this help"
	@echo
	@echo "Variables:"
	@echo
	@echo "- APACHE_BASE_PATH Base path  (current value: $(APACHE_BASE_PATH))"
	@echo "- APACHE_BASE_DIRECTORY       (current value: $(APACHE_BASE_DIRECTORY))"
	@echo "- API_URL                     (current value: $(API_URL))"
	@echo "- PYTHONVENV_OPTS             (current value: $(PYTHONVENV_OPTS))"
	@echo


.PHONY: all
all: mapcache \
	apache 

.PHONY: apache
apache: apache/app.conf


.PHONY: config
config: .build-artefacts/python-venv/bin/mapcache \
	mapcache.xml
	touch $@

mapcache.xml:
	$(call check_defined, MAPCACHE_ACCESS_KEY, AWS S3 access key)
	$(call check_defined, MAPCACHE_SECRET_KEY, AWS S3 secret key)
	$(call check_defined, MAPCACHE_BUCKET_NAME, AWS S3 bucket name for cache)
	${PYTHON_CMD} scripts/mapcachify.py $(API_URL)   $< > $@

.build-artefacts/python-venv/bin/mako-render: .build-artefacts/python-venv
	${PYTHON_CMD} .build-artefacts/python-venv/bin/pip install "Mako==1.0.0"
	touch $@
	@ if [[ ! -e .build-artefacts/python-venv/local ]]; then \
		ln -s . .build-artefacts/python-venv/local; \
	fi
	cp scripts/cmd.py .build-artefacts/python-venv/local/lib/python2.7/site-packages/mako/cmd.py


.PHONY: mapcache
mapcache: .build-artefacts/python-venv/bin/mapcache \
	.build-artefacts/python-venv/bin/mako-render \
	mapcache.xml

.build-artefacts/python-venv:
	mkdir -p .build-artefacts
	virtualenv ${PYTHONVENV_OPTS}  $@


scripts/mapproxify.py:
	curl -o scripts/mapproxify.py  'https://raw.githubusercontent.com/geoadmin/service-mapproxy/master/mapproxy/scripts/mapproxify.py' 

.build-artefacts/python-venv/bin/mapcache: .build-artefacts/python-venv \
	scripts/mapproxify.py
	${PYTHON_CMD} .build-artefacts/python-venv/bin/pip install "httplib2==0.9.2"

    

apache/app.conf: apache/app.mako-dot-conf 
	${PYTHON_CMD} .build-artefacts/python-venv/bin/mako-render \
		--var "apache_base_directory=$(APACHE_BASE_DIRECTORY)" \
	    --var "apache_base_path=$(APACHE_BASE_PATH)"  $< > $@


.PHONY: clean
clean:
	rm -rf .build-artefacts
	rm apache/app.conf
	rm mapcache.xml
