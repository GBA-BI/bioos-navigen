.PHONY: all validate compile

all: validate compile

validate:
	python3 validate_prompts.py

compile:
	python3 compile_prompts.py
