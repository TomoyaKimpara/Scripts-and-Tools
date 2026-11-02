"""
 # Object階層のノードを全部非表示
"""


import hou

obj = hou.node("/obj")

for n in obj.allSubChildren():

    # Object階層のノードだけ処理
    if n.type().category() != hou.objNodeTypeCategory():
        continue

    if hasattr(n, "setDisplayFlag"):
        try:
            n.setDisplayFlag(False)
        except hou.PermissionError:
            pass
        except hou.OperationFailed:
            pass

print("All object display flags under /obj turned off.")
