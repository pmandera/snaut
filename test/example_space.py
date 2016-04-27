from semspaces.space import SemanticSpace

import numpy as np


space = np.array([[ 0.61502426,  0.35800892,  0.46591138],
                 [ 0.06256679,  0.80705953,  0.87805124],
                 [ 0.18189868,  0.37707662,  0.89973192],
                 [ 0.32667934,  0.0994168 ,  0.75457225],
                 [ 0.43300126,  0.17586539,  0.88097073],
                 [ 0.62085788,  0.29817756,  0.62991792],
                 [ 0.37163458,  0.86633926,  0.31679958],
                 [ 0.37416635,  0.82935107,  0.34275204],
                 [ 0.26996958,  0.57101081,  0.60706083],
                 [ 0.36690094,  0.70666147,  0.3300295 ],
                 [ 0.19479401,  0.3334173 ,  0.79296408]])

rows = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth',
        'seventh', 'eighth', 'ninth', 'tenth', 'eleventh']
columns = ['one', 'two', 'three']
readme_title = 'Random semantic space'
readme_desc = 'Demo semantic space description.'
example_semspace = SemanticSpace(space, rows, columns,
                                 readme_title, readme_desc)
