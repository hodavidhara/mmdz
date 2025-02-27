```
class DirectedGraph:
    def __init__(self):
        self.graph = {}

    def add_node(self, node):
        if node not in self.graph:
            self.graph[node] = []

    def add_edge(self, source, destination):
         if source in self.graph:
            self.graph[source].append(destination)
         else:
            self.graph[source] = [destination]

    def get_neighbors(self, node):
        return self.graph.get(node, [])

    def get_all_nodes(self):
        return list(self.graph.keys())

    def get_all_edges(self):
        edges = []
        for node, neighbors in self.graph.items():
            for neighbor in neighbors:
                edges.append((node, neighbor))
        return edges

    def print_graph(self):
        for node, neighbors in self.graph.items():
            print(f"Node: {node}, Neighbors: {neighbors}")

# Example usage:
graph = DirectedGraph()
graph.add_node("A")
graph.add_node("B")
graph.add_node("C")
graph.add_node("D")

graph.add_edge("A", "B")
graph.add_edge("B", "C")
graph.add_edge("C", "A")
graph.add_edge("D", "A")

graph.print_graph()
# Expected Output:
# Node: A, Neighbors: ['B']
# Node: B, Neighbors: ['C']
# Node: C, Neighbors: ['A']
# Node: D, Neighbors: ['A']
```