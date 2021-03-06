# Copyright (c) 2015, Loïc Hoguin <essen@ninenines.eu>
# This file is part of erlang.mk and subject to the terms of the ISC License.

ifneq ($(wildcard $(DEPS_DIR)/triq),)
.PHONY: triq

# Targets.

tests:: triq

define triq_check.erl
	code:add_pathsa(["$(CURDIR)/ebin", "$(DEPS_DIR)/*/ebin"]),
	try
		case $(1) of
			all -> [true] =:= lists:usort([triq:check(M) || M <- [$(MODULES)]]);
			module -> triq:check($(2));
			function -> triq:check($(2))
		end
	of
		true -> halt(0);
		_ -> halt(1)
	catch error:undef ->
		io:format("Undefined property or module~n"),
		halt(0)
	end.
endef

ifdef t
ifeq (,$(findstring :,$(t)))
triq: test-build
	@$(call erlang,$(call triq_check.erl,module,$(t)))
else
triq: test-build
	@echo Testing $(t)/0
	@$(call erlang,$(call triq_check.erl,function,$(t)()))
endif
else
triq: test-build
	$(eval MODULES := $(shell find ebin -type f -name \*.beam \
		| sed "s/ebin\//'/;s/\.beam/',/" | sed '$$s/.$$//'))
	$(gen_verbose) $(call erlang,$(call triq_check.erl,all,undefined))
endif
endif
