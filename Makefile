

all: images slides

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

# generate images from drawio diagram
images: venv
	. venv/bin/activate; $(MAKE) -C png all

OUT_DIR=out

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

ifeq (,$(shell which marp))
  MARP=npx @marp-team/marp-cli
else
  MARP=marp
endif

slides: slides_ru.md steps_ru.md $(OUT_DIR)
	$(MARP) steps_ru.md  --allow-local-files --output $(OUT_DIR)/steps_ru.pdf
	$(MARP) slides_ru.md --allow-local-files --output $(OUT_DIR)/slides_ru.pdf
	$(MARP) slides_ru.md --allow-local-files --output $(OUT_DIR)/slides_ru.pptx
	cp png/schoolRISCV.gif $(OUT_DIR)

html:
	npx marp $<  --allow-local-files --output slides.html
