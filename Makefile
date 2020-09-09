

all: out/slides_ru.pdf \
	 out/slides_ru.pptx \
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

# export pptx & pdf
out/slides_ru.pdf: slides_ru.md #marp images out
	npx marp $< --allow-local-files --output $@

out/slides_ru.pptx: slides_ru.md #marp images out
	npx marp $< --allow-local-files --output $@

# export gif
out/schoolRISCV.gif: images out
	cp png/schoolRISCV.gif $@

html:
	npx marp $<  --allow-local-files --output slides.html
