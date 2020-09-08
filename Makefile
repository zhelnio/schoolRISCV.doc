

all: out/slides_ru.pdf \
	 out/schoolRISCV.gif

clean:
	rm -rf venv
	rm -rf out
	$(MAKE) -C png clean

# create python venv
venv:
	python3 -m venv venv
	. venv/bin/activate; \
	pip install pip --upgrade; \
	pip install git+https://github.com/zhelnio/drawio-layer#egg=drawio-layer

# nodejs marp-cli install
marp:
	npm install --save-dev @marp-team/marp-cli

# generate images from drawio diagram
images: venv
	. venv/bin/activate; $(MAKE) -C png all

out:
	mkdir -p out

# create marp slides from markdown and images
out/slides_ru.pdf: marp images out
	npx marp slides_ru.md --allow-local-files --pdf --output $@

# export pptx
out/slides_ru.pptx: marp images out
	npx marp slides_ru.md --allow-local-files --pdf --output $@

# export gif
out/schoolRISCV.gif: images out
	cp png/schoolRISCV.gif $@

html:
	npx marp slides_ru.md --allow-local-files --output slides.html
