import hypernetx as hnx
import pandas as pd
import matplotlib.pyplot as plt
import networkx as nx
import warnings
warnings.simplefilter('ignore')


#dictionary of each years csv data
dataframes = {}


#load the affiliation data of each csv, dropping the observation day column
for yr in range(2007, 2019):
    affiliation = {}
    filepath = f"data/AEaffmat{yr}.csv"
    df = pd.read_csv(filepath)
    affiliation = df.drop(columns=['obsday'])
    dataframes[yr] = affiliation


#build the hyperedges from the affiliation matricies
hypergraphTotalEdges = {}

for yr in range(2007, 2019):
    edges = {}
    for i, row in dataframes[yr].iterrows():
        #all elephants that were seen (1 in csv)
        members = row[row == 1].index.tolist()
        #edges of hypergraphs = groups seen together
        edges[f"group{i}"] = members
    hypergraphTotalEdges[yr] = edges

#-create a text file with readily available information about the hypergraph-

# with open("HyperInfo.txt", "w", encoding = "utf-8") as f:
#     f.write("Hypergraph information \n")
#     f.write("nrows = number of nodes in the hypergraph.\n ncols = number of hyperedges in hypergraph \n")


#create hypergraph
for yr in range(2007, 2019):

    H = hnx.Hypergraph(hypergraphTotalEdges[yr])

     #-for text file formatting-

    #HyperInfo = f"{yr} data : {hnx.info_dict(H)}"

    # #append text file with each year's hypergraph information
    # with open("HyperInfo.txt", "a", encoding = "utf-8") as f:
    #     f.write(f"{HyperInfo}. \n")

    #create a fixed layout
    B = H.bipartite()
    #pos = nx.spring_layout(B, iterations=500, seed=12)
    
    pos = hnx.drawing.rubber_band.layout_node_link(H, G=None, layout=nx.spring_layout, seed = 111)

    hnx.draw(H, pos = pos, with_node_labels=False, with_edge_labels=False)
    plt.title(str(yr))
    
    #uncomment when saving hypergraphs
    #plt.savefig(f"AffiliationMatrix{yr}NOLABEL.png", dpi=600, bbox_inches= 'tight')
    plt.close()

    