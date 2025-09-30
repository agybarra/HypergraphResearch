import hypernetx as hnx
import pandas as pd
import matplotlib.pyplot as plt
import networkx as nx
import warnings
warnings.simplefilter('ignore')


# Load the affiliation data of each csv, dropping the observation day column

dataframes = {}

for yr in range(2007, 2019):
    affiliation = {}
    filepath = f"data/AEaffmat{yr}.csv"
    df = pd.read_csv(filepath)
    affiliation = df.drop(columns=['obsday'])
    dataframes[yr] = affiliation


#Build the hyperedges from the affiliation matricies
hypergraphTotalEdges = {}

for yr in range(2007, 2019):
    edges = {}
    for i, row in dataframes[yr].iterrows():
        members = row[row == 1].index.tolist()
        edges[f"group{i}"] = members
    hypergraphTotalEdges[yr] = edges


