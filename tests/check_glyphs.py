from fontTools.ttLib import TTFont
from pathlib import Path
p = Path(__file__).resolve().parents[1]
font = TTFont(p / 'assets/NotoSansKR.ttf')
source = (p / 'Main.gd').read_text() + (p / 'project.godot').read_text()
missing = sorted({c for c in source if ord(c) > 127 and ord(c) not in font.getBestCmap()})
print('Missing non-ASCII glyphs:', missing)
assert not missing
print('Korean glyph coverage OK')
