# Lists of all style names supported by each tool
PYGMENTS_STYLES := $(shell python3 -c "from pygments.styles import get_all_styles; print(\"\n\".join(list(get_all_styles())))")
ROUGE_STYLES := $(shell ruby -r rouge -e 'puts (Rouge::CSSTheme.subclasses + Rouge::CSSTheme.subclasses.map(&:subclasses)).flatten.map(&:name)')

# Generate stylesheets for drop-in use in Jekyll and other sites
pygmentize_gen_css = echo "/* This file was generated using \`pygmentize -S $(style) -f html -a .highlight\` */" > Pygments/$(style).css; pygmentize -S $(style) -f html -a .highlight >> Pygments/$(style).css;
rouge_gen_css = echo "/* This file was generated using \`rougify style $(style)\` */" > Rouge/$(shell echo $(style) | sed -e 's/\./-/').css; rougify style $(style) >> Rouge/$(shell echo $(style) | sed -e 's/\./-/').css;

# Generate stylesheets with custom classes prefixed by ".highlight-$(family)-$(style)"
pygmentize_gen_preview_css = pygmentize -S $(style) -f html -a .highlight-pygments-$(style) > gh-pages/stylesheets/pygments/$(style).css;
rouge_gen_preview_css = rougify style $(style) | sed -e 's/.highlight/.highlight-rouge-$(shell echo $(style) | sed -e 's/\./-/')/' > gh-pages/stylesheets/rouge/$(shell echo $(style) | sed -e 's/\./-/').css;

all: deps rouge pygments gh-pages

deps:
	bundle install
	pip install -v -r requirements.txt

pygments: deps
	$(foreach style, $(PYGMENTS_STYLES), $(pygmentize_gen_css))

pygments-previews: deps
	mkdir -p gh-pages/stylesheets/pygments
	$(foreach style, $(PYGMENTS_STYLES), $(pygmentize_gen_preview_css))

rouge: deps
	$(foreach style, $(ROUGE_STYLES), $(rouge_gen_css))

rouge-previews: deps
	mkdir -p gh-pages/stylesheets/rouge
	$(foreach style, $(ROUGE_STYLES), $(rouge_gen_preview_css))

gh-pages: pygments-previews rouge-previews
	./gh-pages/scripts/update_front_matter.rb

FORCE:
