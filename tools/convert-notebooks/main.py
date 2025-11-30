import nbformat
import argparse
from nbconvert import MarkdownExporter
from traitlets.config import Config
from common import StripMagicCellsPreprocessor

"""
Documentation links:
- nbconvert: https://nbconvert.readthedocs.io/en/latest/nbconvert_library.html
    - https://nbconvert.readthedocs.io/en/latest/api/
- nbformat: https://nbformat.readthedocs.io/
"""
def main():
    parser = argparse.ArgumentParser(description="Convert Jupyter Notebooks to Markdown")
    parser.add_argument("input", help="Path to the input Jupyter Notebook (.ipynb) file")
    parser.add_argument("output", help="Path to the output Markdown file")
    args = parser.parse_args()

    # Load the notebook
    with open(args.input, "r", encoding="utf-8") as f:
        notebook = nbformat.read(f, as_version=4)

    # Convert the notebook to Markdown
    config = Config()
    config.MarkdownExporter.preprocessors = [StripMagicCellsPreprocessor]
    exporter = MarkdownExporter(config=config)
    markdown, info = exporter.from_notebook_node(notebook)
    imageFiles = info.get('outputs', {})
    for filename, data in imageFiles.items():
        # with open(f".build/{filename}", "wb") as img_f:
        #     img_f.write(data)
        print(f"Found image: {filename} ({len(data)} bytes)")
    
    # Write the output to the specified file
    with open(args.output, "w", encoding="utf-8") as f:
        f.write(markdown)

    print(f"Converted {args.input} to {args.output}")

if __name__ == "__main__":
    main()
