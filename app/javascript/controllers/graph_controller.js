import { Controller } from "@hotwired/stimulus"
import dagre from "@dagrejs/dagre"

// Lays out the dependency graph.
//
// The nodes and edges are already on the page, drawn server-side as links and
// empty paths. All that happens here is arithmetic: measure each node, ask
// dagre where it goes, and move it there. Theming is handled entirely by CSS.
//
// Connects to `data-controller="graph"`
export default class extends Controller {
  static targets = ["canvas", "nodes", "edges", "node"]
  static values = { edges: Array }

  // Room around the drawing, and between ranks and nodes.
  static PADDING = 28
  static RANK_SEPARATION = 110
  static NODE_SEPARATION = 24

  connect() {
    // Observing calls back immediately, so this is the first layout and all
    // subsequent ones. The canvas has no width until its tab opens.
    this.observer = new ResizeObserver(() => this.layout())
    this.observer.observe(this.canvasTarget)

    // A node is as wide as its text, and its text changes width when the
    // fonts arrive.
    document.fonts?.ready?.then(() => this.layout())
  }

  disconnect() {
    this.observer?.disconnect()
  }

  layout() {
    if (this.canvasTarget.clientWidth === 0) return

    const placed = this.place()
    if (!placed) return

    this.drawNodes(placed)
    this.drawEdges(placed)
    this.element.dataset.graphLaidOut = "true"
  }

  // Works out where every node goes.
  //
  // Dependencies rank left to right, so what uses this entity sits to its
  // left and what it uses sits to its right. The server marks the nodes that
  // are context rather than a step in that chain -- the system an entity
  // belongs to -- and those are left out of the ranking and put in a row
  // underneath, where they cannot distort it.
  place() {
    const graph = new dagre.graphlib.Graph()
    graph.setGraph({
      rankdir: "LR",
      ranksep: this.constructor.RANK_SEPARATION,
      nodesep: this.constructor.NODE_SEPARATION,
      marginx: this.constructor.PADDING,
      marginy: this.constructor.PADDING
    })
    graph.setDefaultEdgeLabel(() => ({}))

    const ranked = this.nodeTargets.filter((node) => node.dataset.aside !== "true")
    if (ranked.length === 0) return null

    ranked.forEach((node) => {
      graph.setNode(node.dataset.id, {
        width: node.offsetWidth,
        height: node.offsetHeight
      })
    })

    this.edgesValue.forEach((edge) => {
      if (graph.hasNode(edge.source) && graph.hasNode(edge.target)) {
        graph.setEdge(edge.source, edge.target)
      }
    })

    dagre.layout(graph)

    const placed = {}
    ranked.forEach((node) => {
      const { x, y } = graph.node(node.dataset.id)

      placed[node.dataset.id] = { node, x, y }
    })

    return this.placeAsides(placed, graph.graph())
  }

  // Puts the context nodes in a row under everything else.
  placeAsides(placed, size) {
    const asides = this.nodeTargets.filter((node) => node.dataset.aside === "true")
    const width = size.width || this.canvasTarget.clientWidth
    const step = width / (asides.length + 1)

    asides.forEach((node, index) => {
      placed[node.dataset.id] = {
        node,
        x: step * (index + 1),
        y: (size.height || 0) + this.constructor.PADDING + node.offsetHeight
      }
    })

    return placed
  }

  // Moves each node to its place.
  //
  // A graph too big for the canvas is scaled by transforming the layers the
  // nodes and edges sit in, so that the nodes shrink with the distances
  // between them. Scaling the positions alone would slide the nodes together
  // until they overlapped, and push the outermost ones off the canvas.
  drawNodes(placed) {
    const entries = Object.values(placed)
    const bounds = this.boundsOf(entries)
    const scale = Math.min(
      1,
      (this.canvasTarget.clientWidth - this.constructor.PADDING) / bounds.width,
      (this.canvasTarget.clientHeight - this.constructor.PADDING) / bounds.height
    )

    const transform = [
      `translate(${(this.canvasTarget.clientWidth - bounds.width * scale) / 2}px,`,
      `${(this.canvasTarget.clientHeight - bounds.height * scale) / 2}px)`,
      `scale(${scale})`,
      `translate(${-bounds.left}px, ${-bounds.top}px)`
    ].join(" ")

    ;[ this.nodesTarget, this.edgesTarget ].forEach((layer) => {
      layer.style.transformOrigin = "0 0"
      layer.style.transform = transform
    })

    entries.forEach(({ node, x, y }) => {
      node.style.transform =
        `translate(${x - node.offsetWidth / 2}px, ${y - node.offsetHeight / 2}px)`
    })
  }

  // Joins each edge's two nodes with a curve.
  drawEdges(placed) {
    this.edgesTarget.querySelectorAll("path").forEach((path) => {
      const from = placed[path.dataset.source]
      const to = placed[path.dataset.target]

      if (!from || !to) return path.removeAttribute("d")

      const bend = (from.x + to.x) / 2

      path.setAttribute(
        "d",
        `M${from.x},${from.y} C${bend},${from.y} ${bend},${to.y} ${to.x},${to.y}`
      )
    })
  }

  // The box every node sits inside, in the layout's own coordinates.
  boundsOf(entries) {
    const xs = entries.flatMap(({ node, x }) => [ x - node.offsetWidth / 2, x + node.offsetWidth / 2 ])
    const ys = entries.flatMap(({ node, y }) => [ y - node.offsetHeight / 2, y + node.offsetHeight / 2 ])
    const left = Math.min(...xs)
    const top = Math.min(...ys)

    return {
      left,
      top,
      width: Math.max(...xs) - left || 1,
      height: Math.max(...ys) - top || 1
    }
  }
}
