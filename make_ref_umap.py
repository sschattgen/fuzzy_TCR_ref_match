import os
import pandas as pd
import numpy as np
from sknetwork.utils import KNNDense
from sklearn.decomposition import KernelPCA
from sknetwork.clustering import Louvain
import umap
from conga.preprocess import calc_tcrdist_matrix_cpp

working_dir = '/Users/sschattg/fuzzy_TCR_ref_match/'
os.chdir(working_dir)

# in/out
organism = 'human'
df = pd.read_csv('data/new_paired_tcr_db_for_matching_nr.tsv', sep='\t')
df = df[df.db == 'vdjdb']
new_cols = {"va":"va_gene", "ja" :"ja_gene", "vb":"vb_gene", "jb" :"jb_gene"}
df = df.rename(columns = new_cols)
# tuples of tuples with tcr info
tcrs = [((l.va_gene, l.ja_gene, l.cdr3a),
         (l.vb_gene, l.jb_gene, l.cdr3b)) for l in df.itertuples()]

# calc tcrdist with C++ TCRdist calculator, which needs to be compiled
D_cpp = calc_tcrdist_matrix_cpp(tcrs, organism)

#smooth with kPCA
transformer = KernelPCA(n_components=50, kernel='linear')
tcrdist_mat_kpc = transformer.fit_transform(D_cpp)
    
"""
neighbor graph, clustering, and embedding
"""
louvain = Louvain()
k = D_cpp.shape[0] // 100
knn = KNNDense(n_neighbors=k)
adjacency = knn.fit_transform(tcrdist_mat_kpc)
labels = louvain.fit_transform(adjacency)
reducer = umap.UMAP()
embedding = reducer.fit_transform(tcrdist_mat_kpc)

umap_df = (pd.DataFrame(embedding).
 rename({0:'UMAP1', 1:'UMAP2'}, axis=1) 
 )
umap_df['cluster'] = pd.Series(labels)
df = df.join(umap_df)
df.to_csv('data/new_paired_tcr_db_for_matching_nr.tsv.clustered.tsv',sep ='\t', index =False)
