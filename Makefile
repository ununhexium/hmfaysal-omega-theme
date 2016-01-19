DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

IMG_REMOTE=$(HOME)/hubic/Data/rtw/img/
IMG_LOCAL=$(DIR)/_src_images/
SERVER=lab0.net
SERVER_USER=ununhexium
include env
DATETIME=$(shell date '+%Y-%m-%d_%H-%M')

RSYNC_OPT=--no-perms --no-owner --no-group --verbose --recursive --update

default: info
	@echo 
	@echo "all:      clean, img, build, upload"
	@echo "clean:    removes generated files"
	@echo "img:      fetches images from hubic and puts them in the $(DIR)/images folder"
	@echo "info:     displays the above information"
	@echo "local:    cleans and builds a local site"
	@echo "server:   starts the jekyll local server"
	@echo "upload:   uploads the website to $(SERVER)"

all: clean upload

backup:
	echo $(DATETIME)
	rsync -arv $(DIR)/_site/ $(HOME)/backup/blog/$(DATETIME)

clean:
	cd $(DIR); rm -rf _site
	cd $(DIR)/_plugins; rm -f jekyll_geocache.json

img: img-get img-process

img-get:
	mount | grep hubic || hubicfuse ~/.hubicmount -o noauto_cache,sync_read
	mkdir -p "$(IMG_LOCAL)"
	rsync $(RSYNC_OPT) $(IMG_REMOTE) $(IMG_LOCAL)

img-process:
	_scripts/img-process.zsh "$(IMG_LOCAL)" "$(DIR)/images"

info:
	@echo Makefile directory "$(DIR)"
	@echo Local images dir "$(IMG_LOCAL)"
	@echo Backed images dir "$(IMG_REMOTE)"

local: clean img build
	

put-img:
	rsync $(RSYNC_OPT) $(IMG_LOCAL) $(IMG_REMOTE)

serve: server
	echo e

server:
	cd $(DIR); jekyll server --incremental --config "$(DIR)/_config.yml,$(DIR)/_config.local.yml" --host $(IP) --baseurl ''

upload: img
	@echo Clean and rebuild with the prod config
	cd $(DIR); rm -rf _site
	cd $(DIR); jekyll build
	@echo Upload to $(SERVER_USER)@$(SERVER)
	rsync -vrz $(DIR)/_site/ $(SERVER_USER)@$(SERVER):/home/$(SERVER_USER)/html/

