from traitlets import Integer
from nbconvert.preprocessors import Preprocessor
import nbformat.v4 as nbf

class StripMagicCellsPreprocessor(Preprocessor):
    """
    A preprocessor to strip out cells that contain Jupyter magic commands.
    See https://nbformat.readthedocs.io/en/latest/api.html for more details on notebook format.
    """

    magic_command_prefix: str = "%"

    def preprocess_cell(self, cell, resources, index):
        if cell.cell_type == "code":
            source_lines = cell.source.splitlines()
            if any(line.strip().startswith(self.magic_command_prefix) for line in source_lines):
                # Skip this cell
                print(f"Stripping cell at index {index} containing magic command.")
                print(f"{"---" * 3}\nCell source:\n{cell.source}\n{"---" * 3}")
                return nbf.new_raw_cell(), resources
        return cell, resources