DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

IMG_REMOTE=$(HOME)/hubic/Data/rtw/img/
IMG_LOCAL=$(DIR)/images/
SERVER=lab0.net
SERVER_USER=ununhexium
# := evaluates only once
IP:=$(shell ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

RSYNC_OPT=--no-perms --no-owner --no-group --verbose --recursive --update

get-img:
	rsync $(RSYNC_OPT) $(IMG_REMOTE) $(IMG_LOCAL)

put-img:
	rsync $(RSYNC_OPT) $(IMG_LOCAL) $(IMG_REMOTE)

img: get-img

info:
	@echo Makefile directory "$(DIR)"
	@echo Local images dir "$(IMG_LOCAL)"
	@echo Backed images dir "$(IMG_REMOTE)"

build:
	cd $(DIR); jekyll build

serve: server

server:
	cd $(DIR); jekyll server --host $(IP) --baseurl ''

upload: img build
	@echo Upload to $(SERVER_USER)@$(SERVER)
	rsync --delete -vr $(DIR)/_site/ $(SERVER_USER)@$(SERVER):/home/$(SERVER_USER)/html/

