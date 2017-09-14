SOURCE     := src
IMAGE      := ucore
CONTAINER  := ucore-container
# NETWORK    := ucore-net
WORKDIR	   := /usr/src/app

VOLFLAGS   := -v $(CURDIR)/$(SOURCE):$(WORKDIR)
# NETFLAGS   := --net=$(NETWORK)
# PORTFLAGS  := -p 5522:22

BASH       := /bin/bash
QEMU       := qemu
QEMUFLAGS  := -s -S
GDB        := gdb
GDBINIT    := tools/gdbinit
GDBFLAGS   := -q -x $(GDBINIT)

LOCALIP = $(shell ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}')
# TODO: Get windows ip addr
# LOCALIP = 59.66.134.33

DFLAGS     := --privileged --rm -itd $(VOLFLAGS)
DFLAGS_G   := $(DFLAGS) -e DISPLAY=$(LOCALIP):0 -v /tmp/.X11-unix:/tmp/.X11-unix

docker_run          = docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE)
docker_run_graphics = docker run $(DFLAGS_G) --name $(CONTAINER) $(IMAGE)
docker_exec         = docker exec -it $(CONTAINER)

docker_bash = $(docker_run) $(BASH) -c "$(1)"

# ifeq ($(OS),Windows_NT)
# else
#     UNAME_S := $(shell uname -s)
#     ifeq ($(UNAME_S),Linux)

#     endif
#     ifeq ($(UNAME_S),Darwin)

#     endif
# endif

# Get the Ubuntu environment
exec:
	$(docker_exec) $(BASH)

# https://fredrikaverpil.github.io/2016/07/31/docker-for-mac-and-gui-applications/
config:
	xhost + $(LOCALIP)

config-cygwin:
	export DISPLAY=$(LOCALIP)
	startxwin -- -listen tcp &
	xhost + $(LOCALIP)

# main
start: build run

build:
	docker build -t $(IMAGE) .

run:
	$(call docker_run_graphics) $(BASH)


debug-qemu:
	$(docker_exec) $(QEMU) $(QEMUFLAGS) bin/bootblock

debug-gdb:
	$(docker_exec) $(GDB) $(GDBFLAGS)

# extra inner copy
clean:
	@$(call docker_bash,make clean)
