DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

IMG_REMOTE=$(HOME)/hubic/Data/rtw/img/
IMG_LOCAL=$(DIR)/images/
SERVER=lab0.net
SERVER_USER=ununhexium
include env

RSYNC_OPT=--no-perms --no-owner --no-group --verbose --recursive --update

default: info
	@echo 
	@echo "all:      clean, img, build, upload"
	@echo "build:    builds the web site"
	@echo "clean:    removes generated files"
	@echo "img:      fetches images from hubic and puts them in the $(DIR)/images folder"
	@echo "info:     displays the above information"
	@echo "server:   starts the jekyll local server"
	@echo "upload:   uploads the website to $(SERVER)"

build:
	cd $(DIR); jekyll build

clean:
	cd $(DIR); rm -rf "_site"
	cd $(DIR)/_plugins; rm jekyll_geocache.json

get-img:
	rsync $(RSYNC_OPT) $(IMG_REMOTE) $(IMG_LOCAL)

put-img:
	rsync $(RSYNC_OPT) $(IMG_LOCAL) $(IMG_REMOTE)

img: get-img

info:
	@echo Makefile directory "$(DIR)"
	@echo Local images dir "$(IMG_LOCAL)"
	@echo Backed images dir "$(IMG_REMOTE)"

serve: server

server:
	cd $(DIR); jekyll server --host $(IP) --baseurl ''

upload: img build
	@echo Upload to $(SERVER_USER)@$(SERVER)
	rsync --delete -vr $(DIR)/_site/ $(SERVER_USER)@$(SERVER):/home/$(SERVER_USER)/html/

