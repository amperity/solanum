# Build file for Solanum

default: package

.PHONY: setup clean lint test uberjar package

uberjar_path := target/uberjar/solanum.jar
version := $(shell grep defproject project.clj | cut -d ' ' -f 3 | tr -d \")
platform := $(shell uname -s | tr '[:upper:]' '[:lower:]')
release_name := solanum_$(version)_$(platform)

ifndef GRAAL_PATH
$(error GRAAL_PATH is not set)
endif

setup:
	lein deps

clean:
	rm -rf target dist solanum

lint:
	lein check

test:
	lein test

$(uberjar_path): src/**/* resources/* svm/java/**/*
	lein with-profile +svm uberjar

uberjar: $(uberjar_path)

# TODO: further options
# --static
solanum: reflection-config := svm/reflection-config.json
solanum: $(uberjar_path) $(reflection-config)
	$(GRAAL_PATH)/bin/native-image \
	    --report-unsupported-elements-at-runtime \
	    -H:ReflectionConfigurationFiles=$(reflection-config) \
		--initialize-at-run-time=io.netty.handler.ssl.ConscryptAlpnSslEngine \
		--initialize-at-run-time=io.netty.handler.ssl.ReferenceCountedOpenSslEngine \
		--initialize-at-run-time=io.netty.util.internal.logging.Log4JLogger \
		--initialize-at-build-time=io.netty.buffer.PooledByteBufAllocator \
		--initialize-at-build-time=io.netty.buffer.PooledByteBufAllocator\$$PoolThreadLocalCache \
		--initialize-at-build-time=io.netty.buffer \
		--initialize-at-build-time=io.netty.channel.AbstractChannel \
		--initialize-at-build-time=io.netty.channel.ChannelOutboundBuffer \
		--initialize-at-build-time=io.netty.channel.ChannelOutboundBuffer\$$1 \
		--initialize-at-build-time=io.netty.channel.DefaultChannelPipeline \
		--initialize-at-build-time=io.netty.channel.DefaultChannelPipeline\$$1 \
		--initialize-at-build-time=io.netty.channel.AbstractChannelHandlerContext\$$WriteAndFlushTask \
		--initialize-at-build-time=io.netty.channel.AbstractChannelHandlerContext\$$WriteAndFlushTask\$$1 \
		--initialize-at-build-time=io.netty.channel.ChannelOutboundBuffer\$$Entry \
		--initialize-at-build-time=io.netty.channel.ChannelOutboundBuffer\$$Entry\$$1 \
		--initialize-at-build-time=io.netty.buffer.PooledUnsafeDirectByteBuf\$$1 \
		--initialize-at-build-time=io.netty.util.Recycler\$$3 \
		--initialize-at-build-time=io.netty.util.Recycler\$$2 \
		--initialize-at-build-time=io.netty.util.Recycler\$$1 \
		--initialize-at-build-time=io.netty.util.ResourceLeakDetector \
		--initialize-at-build-time=io.netty.util.ReferenceCountUtil \
		--initialize-at-build-time=io.netty.util.internal.LongAdderCounter \
		--initialize-at-build-time=io.netty.handler.codec.CodecOutputList \
		--initialize-at-build-time=io.netty.handler.codec.CodecOutputList\$$1 \
		--initialize-at-build-time=io.netty.handler.codec.CodecOutputList\$$2 \
		--initialize-at-build-time=io.netty.handler.codec.CodecOutputList\$$CodecOutputLists \
		--initialize-at-build-time=ch.qos.logback \
		--initialize-at-build-time=ch.qos.logback.classic.Logger \
		--initialize-at-build-time=io.netty.util.ResourceLeakDetector\$$Level \
		--initialize-at-build-time=io.netty.util.internal.logging.Slf4JLogger \
		--features=clj_easy.graal_build_time.InitClojureClasses \
	    --no-server \
	  --enable-url-protocols=http,https \
		-J-Xms3G -J-Xmx3G \
		-H:+ReportExceptionStackTraces \
	    -jar $<

dist/$(release_name).tar.gz: solanum
	@mkdir -p dist
	tar -cvzf $@ $^

package: dist/$(release_name).tar.gz
