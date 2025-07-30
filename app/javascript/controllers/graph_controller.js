import { Controller } from "@hotwired/stimulus"
import cytoscape from "cytoscape"

export default class extends Controller {
  static targets = [ "container" ]
  static values = { url: String }

  connect() {
    this.fetchDataAndRenderGraph()
  }

  async fetchDataAndRenderGraph() {
    try {
      const response = await fetch(this.urlValue)
      if (!response.ok) throw new Error('Network response was not ok');
      const graphData = await response.json()
      this.render(graphData)
    } catch (error) {
      console.error("Could not fetch or render graph:", error)
      this.containerTarget.innerHTML = '<p class="text-red-500">Could not load dependency graph.</p>'
    }
  }

  render(data) {
    // Convert the data from our controller's format to the expected format.
    const elements = [
      ...data.nodes.map(node => ({ data: { id: node.id, label: node.label, type: node.type } })),
      ...data.edges.map(edge => ({ data: { source: edge.source, target: edge.target } }))
    ];

    cytoscape({
      container: this.containerTarget,
      elements: elements,
      style: [
        {
          // Default styles for all nodes.
          selector: 'node',
          style: {
            'label': 'data(label)',
            'color': document.body.classList.contains('dark') ? '#ffffff' : '#1f2937',
            // Text styling.
            'font-size': '10px',
            'text-wrap': 'wrap',
            'text-max-width': '80px',
            'text-valign': 'center',
            'text-halign': 'center',
            // Label background styles.
            'text-background-color': document.body.classList.contains('dark') ? '#1f2937' : '#ffffff',
            'text-background-opacity': 0.8,
            'text-background-padding': '2px'
          }
        },
        {
          // Styles for services.
          selector: 'node[type="service"]',
          style: {
            'background-color': '#3b82f6',
            'shape': 'ellipse'
          }
        },
        {
          // Styles for projects.
          selector: 'node[type="project"]',
          style: {
            'background-color': '#10b981',
            'shape': 'round-rectangle'
          }
        },
        {
          // Highlight the current node.
          selector: `node[id = "${data.current_node_id}"]`,
          style: {
            'border-width': 4,
            'border-color': '#f59e0b'
          }
        },
        {
          // Default styles for edges.
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#9ca3af',
            'target-arrow-color': '#9ca3af',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
          }
        }
      ],
      layout: {
        name: 'cose',
        fit: true,
        padding: 30,
        animate: false,
        nodeRepulsion: 40000,
        idealEdgeLength: 100
      },
      zoomingEnabled: true,
      userZoomingEnabled: true,
      panningEnabled: true,
      userPanningEnabled: true
    });
  }
}
