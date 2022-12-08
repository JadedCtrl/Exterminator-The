mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

love:
	zip -9r bin/exterminator,the.love ./*

win32: love
ifeq (,$(wildcard bin/love-win32.zip))
	wget -O bin/love-win32.zip \
		https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip
endif
	unzip -d bin/ bin/love-win32.zip
	mv bin/love-*-win32 bin/exterminator,the-win32
	rm bin/exterminator,the-win32/changes.txt
	rm bin/exterminator,the-win32/readme.txt
	rm bin/exterminator,the-win32/lovec.exe
	cat bin/exterminator,the.love >> bin/exterminator,the-win32/love.exe
	mv bin/exterminator,the-win32/love.exe bin/exterminator,the-win32/Exterminator,The.exe
	cp lib/bin-license.txt bin/exterminator,the-win32/license.txt
	zip -9jr bin/exterminator,the-win32.zip bin/exterminator,the-win32
	rm -rf bin/exterminator,the-win32

test: love
	love bin/exterminator,the.love

clean:
	rm -rf ./bin/*

all: love win32
