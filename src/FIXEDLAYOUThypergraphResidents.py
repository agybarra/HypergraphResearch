import hypernetx as hnx
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import networkx as nx
import warnings
import numpy as np
import math
warnings.simplefilter('ignore')


#import the resident csv

resNames = f"data/resnames_20250922(in).csv"
resDF = pd.read_csv(resNames, header=None,names=["elephant_id"])

#pad the resident list with 00s to match the strings in AEaffmat, make sure the length of string is 3
#create a set for matching (no duplicates)

residents = set(f"{r:03d}" for r in resDF["elephant_id"])

#dictionary of each years csv data
dataframes = {}


#load the affiliation data of each csv, dropping the observation day column

for yr in range(2007, 2019):
    filepath = f"data/AEaffmat{yr}.csv"
    df = pd.read_csv(filepath).drop(columns=['obsday'])
    dataframes[yr] = df

#generate set pos for res
resident_list = sorted(residents)
n = len(resident_list)
cols = int(math.ceil(n**0.5))
rows = int(math.ceil(n / cols))

fixed_pos = {}
for i, res in enumerate(resident_list):
    row = i // cols
    col = i % cols
    fixed_pos[res] = (col, -row)

#build the hyperedges from the affiliation matricies
hypergraphTotalEdges = {}

for yr in range(2007, 2019):
    edges = {}
    df = dataframes[yr]
    for i, aff_row in df.iterrows():
        #all elephants that were seen (1 in csv)
        members = aff_row[aff_row == 1].index.tolist()
        #if the elephant is in the resident list
        if any(e in residents for e in members):
            edges[f"group{i}"] = members
    hypergraphTotalEdges[yr] = edges


#-create a text file with readily available information about the hypergraph-

# with open("resHyperInfo", "w", encoding = "utf-8") as f:
#         f.write("Hypergraph information \n")
#         f.write("nrows = number of nodes in the hypergraph.\n ncols = number of hyperedges in hypergraph. \n")

#create hypergraph
for yr in range(2007, 2019):
    H = hnx.Hypergraph(hypergraphTotalEdges[yr])


    #-for text file formatting-
    #resHyperInfo = f"{yr} data : {hnx.info_dict(H)}"
    
    #append text file with each year's hypergraph information
    # with open("resHyperInfo", "a", encoding = "utf-8") as f:
    #     f.write(f"{resHyperInfo}. \n")


    #create a fixed layout
    B = H.bipartite()
    
    #use fixed position
    pos = hnx.drawing.rubber_band.layout_node_link(H, layout=nx.spring_layout, fixed=fixed_pos.keys(), pos=fixed_pos, seed=111)

    #using matplotlib.collections layout for coloring methods
    node_color = {
        'facecolors': ['mediumseagreen' if n in residents else 'royalblue' for n in H.nodes],
        'edgecolors': 'black',  # optional border color
        'linewidths': 0.5,      # optional
    }


    fig, ax = plt.subplots()
    hnx.draw(H, pos = pos, with_node_labels=False, with_edge_labels=False, nodes_kwargs=node_color)
    plt.title(str(yr))

    #add legend
    green_patch = mpatches.Patch(color='mediumseagreen', label='Residents')
    blue_patch = mpatches.Patch(color='royalblue', label='Non-residents')
    ax.legend(handles=[green_patch,blue_patch])


    #uncomment when saving hypergraphs
    plt.savefig(f"FIXEDLAYOUTresAffiliationMatrix{yr}.png", bbox_inches ='tight')
    
    plt.close()