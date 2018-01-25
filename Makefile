.PHONY: all clean

TARGET = electrod

all: build

build:
	jbuilder build @install --dev \
	&& ln -sf _build/install/default/bin/$(TARGET) ./$(TARGET)

watch:
	while find src/ -print0 | \
		xargs -0 inotifywait -e delete_self -e modify ;\
	do \
		make ; \
	done

doc:
	BROWSER=x-www-browser topkg doc -r

install: build
	@jbuilder install

uninstall:
	@jbuilder uninstall

clean:
	@jbuilder clean
	@git clean -dfXq
	@rm -f ./$(TARGET)
