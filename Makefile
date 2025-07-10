# ZeroTrace - Main Makefile Proxy
# This file redirects to the build system

# Redirect to build system (for all commands)
include build/make/Makefile

# Additional rules for shortcuts
.PHONY: clean-all

clean-all:
	@echo "🧹 Cleaning all temporary files..."
	rm -rf runtime/cache/* 2>/dev/null || true
	rm -rf runtime/build/* 2>/dev/null || true  
	rm -rf runtime/temp/* 2>/dev/null || true
	@echo "✅ Cleanup completed!"
