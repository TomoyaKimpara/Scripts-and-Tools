"""
シーンファイルのフォルダを開く
"""

import os
path = hou.hscriptExpression('$HIP')
path = os.path.realpath(path)
os.startfile(path)
#linux version change last line by this :
#os.system('xdg-open "%s"' % path)
