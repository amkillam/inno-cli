PROJECT = inno-cli
ifdef OS
	RMDIR = del /Q /S
	MKDISTDIR = if not exist dist mkdir dist
	COPY = copy
	EXE = .exe
else
	RMDIR = rm -rf
	MKDISTDIR = mkdir -p dist
	COPY = cp
	EXE = ""
endif

all: clean pascal rust_release
release: all
test: clean pascal rust_test
.NOTPARALLEL:

clean:
	$(RMDIR) dist
pascal:
	make -C ps
rust_test: 
	cd rs && \
	cargo clean && \
	cargo test
rust_release:
	$(MKDISTDIR)
	cd rs && \
	cargo clean && \
	cargo build --release
	$(COPY) rs/target/release/$(PROJECT)$(EXE) dist/$(PROJECT)$(EXE)

