# -*- mode: python -*-

icon_path = 'utils/windows/icon.ico'

block_cipher = None

sklearn_hiddenimports = ['sklearn.utils.sparsetools._graph_validation',
			 'sklearn.utils.sparsetools._graph_tools',
			 'sklearn.utils.lgamma',
			 'sklearn.utils.weight_vector']

a = Analysis(['snaut/snaut.py'],
             pathex=['snaut/'],
             hiddenimports=[] + sklearn_hiddenimports,
             hookspath=None,
             runtime_hooks=None,
             cipher=block_cipher)

pyz = PYZ(a.pure,
             cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          exclude_binaries=True,
          name='snaut.exe',
          debug=False,
          strip=None,
          upx=True,
          console=True,
	  icon=icon_path)
	  
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=None,
               upx=True,
               name='snaut')
