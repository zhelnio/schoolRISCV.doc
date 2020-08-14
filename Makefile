
clean:
	rm -rf venv
	rm -rf out

# create python venv
venv:
	python3 -m venv venv
	. venv/bin/activate; \
	pip install pip --upgrade; \
	pip install git+https://github.com/zhelnio/drawio-layer#egg=drawio-layer

.PHONY: png

marp:
	npm install --save-dev @marp-team/marp-cli

png:
	. venv/bin/activate; $(MAKE) -C png all

pdf:
	npx marp slides_ru.md --pdf --allow-local-files --output out/slides_ru.pdf
