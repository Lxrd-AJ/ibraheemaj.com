# /// script
# requires-python = ">=3.14"
# dependencies = [
#   "jupyter>=1.1.1",
#   "nbconvert>=7.16.6",
# ]
# ///
import nbformat
import argparse
from pathlib import Path
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
    parser.add_argument("input", type=Path, help="Path to the input Jupyter Notebook (.ipynb) file")
    parser.add_argument("output", help="Path to the output Markdown file")
    args = parser.parse_args()

    # Load the notebook
    notebookName = args.input.name
    print(f"Converting notebook: {notebookName}")
    with open(args.input, "r", encoding="utf-8") as f:
        notebook = nbformat.read(f, as_version=4)

    # Convert the notebook to Markdown
    config = Config()
    config.MarkdownExporter.preprocessors = [StripMagicCellsPreprocessor]
    exporter = MarkdownExporter(config=config)
    markdown, info = exporter.from_notebook_node(notebook)
    
    # Write the output to the specified file
    buildDir = Path(args.output).parent
    print(f"Ensuring build directory exists: {buildDir}")
    buildDir.mkdir(parents=True, exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as f:
        f.write(markdown)
    # Write out any extracted images to the build directory
    imageFiles = info.get('outputs', {})
    for filename, data in imageFiles.items():
        targetFile = buildDir / filename
        with open(targetFile, "wb") as img_f:
            img_f.write(data)
        print(f"Written image: {filename} ({len(data)} bytes)")

    print(f"Converted {args.input} to {args.output}")

if __name__ == "__main__":
    main()
