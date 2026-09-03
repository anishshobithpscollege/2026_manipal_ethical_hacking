#import "/template/lib.typ": *
#import "@preview/cetz:0.5.2"

#show: assignment.with(
  title: "Network Models and Routing for a Campus and Enterprise WAN",
  number: "Assignment 01",
  kind: "Theory",
  date: datetime(year: 2026, month: 9, day: 3),
)

#show figure: set block(breakable: true)

#let ink = theme.ink
#let muted = theme.muted
#let c-app = rgb("#e8eef9")
#let c-trn = rgb("#e6f2ea")
#let c-net = rgb("#fdeaea")
#let c-lnk = rgb("#fbf1dd")
#let c-box = rgb("#f5f5f5")

// Figure 1: OSI <-> TCP/IP, protocols, and encapsulation.
#let d-stack = cetz.canvas({
  import cetz.draw: *
  let w = 3.2
  let rh = 0.82
  let names = ("Physical", "Data Link", "Network", "Transport", "Session", "Presentation", "Application")
  let fills = (c-lnk, c-lnk, c-net, c-trn, c-app, c-app, c-app)
  for i in range(7) {
    let yb = i * rh
    rect((0, yb), (w, yb + rh), stroke: 0.5pt + muted, fill: fills.at(i))
    content((w / 2, yb + rh / 2), text(9pt)[#(i + 1). #names.at(i)])
  }
  content((w / 2, 7 * rh + 0.35), text(9pt, weight: "bold")[OSI  (7 layers)])

  let bx0 = 4.6
  let bx1 = 8.4
  let bcx = (bx0 + bx1) / 2
  let tcp = (
    ("Network Access", "Ethernet · Wi-Fi", 0, 2 * rh, c-lnk),
    ("Internet", "IP · ARP", 2 * rh, 3 * rh, c-net),
    ("Transport", "TCP · UDP", 3 * rh, 4 * rh, c-trn),
    ("Application", "HTTP · HTTPS · DNS · TLS", 4 * rh, 7 * rh, c-app),
  )
  for row in tcp {
    let (nm, protos, yb, yt, fl) = row
    rect((bx0, yb), (bx1, yt), stroke: 0.5pt + muted, fill: fl)
    content((bcx, (yb + yt) / 2), align(center)[
      #text(9pt, weight: "bold")[#nm] \ #text(7.5pt, fill: muted)[#protos]
    ])
  }
  content((bcx, 7 * rh + 0.35), text(9pt, weight: "bold")[TCP/IP  (4 layers)])

  let pdu = (("Frame / Bits", rh), ("Packet", 2.5 * rh), ("Segment", 3.5 * rh), ("Data", 5.5 * rh))
  for p in pdu {
    content((bx1 + 1.0, p.at(1)), text(8pt, style: "italic", fill: muted)[#p.at(0)])
  }

  line((-0.7, 7 * rh - 0.1), (-0.7, 0.1), stroke: 1pt + ink, mark: (end: ">"))
  content((-1.15, 3.5 * rh), angle: 90deg, text(8pt)[encapsulate (add headers)])
})

// Figure 2: end-to-end path.
#let d-path = cetz.canvas({
  import cetz.draw: *
  let bh = 0.95
  let boxes = (
    (0, 1.8, "Student\nlaptop"),
    (3.0, 4.9, "Access\npoint"),
    (6.1, 8.4, "Campus\nrouter (NAT)"),
    (11.4, 13.4, "Cloud\nserver"),
  )
  for b in boxes {
    let (x0, x1, t) = b
    rect((x0, 0), (x1, bh), stroke: 0.6pt + muted, fill: c-box)
    content(((x0 + x1) / 2, bh / 2), text(9pt)[#t.split("\n").join([\ ])])
  }
  circle((10.0, bh / 2), radius: 0.72, stroke: 0.6pt + muted, fill: c-net)
  content((10.0, bh / 2), text(8pt)[Internet])
  let seg(x0, x1, lbl) = {
    line((x0, bh / 2), (x1, bh / 2), stroke: 0.8pt + ink, mark: (end: ">"))
    content(((x0 + x1) / 2, bh / 2 + 0.32), text(8pt, fill: muted)[#lbl])
  }
  seg(1.8, 3.0, "Wi-Fi")
  seg(4.9, 6.1, "Ethernet")
  seg(8.4, 9.28, "")
  seg(10.72, 11.4, "")
  content((6.7, -0.75), align(center)[
    #text(8pt)[MAC address: a new pair on every hop] \
    #text(8pt)[IP address: unchanged end to end (NAT rewrites the source at the edge)]
  ])
})

// Figure 3: route types on a branch-to-HQ link.
#let d-routes = cetz.canvas({
  import cetz.draw: *
  let bh = 0.9
  let my = 2 + bh / 2
  rect((0, 2), (2.0, 2 + bh), stroke: 0.6pt + muted, fill: c-box, name: "r1")
  content("r1", text(9pt)[Branch R1])
  rect((5.4, 2), (7.4, 2 + bh), stroke: 0.6pt + muted, fill: c-box, name: "r2")
  content("r2", text(9pt)[HQ R2])
  circle((10.2, my), radius: 0.72, stroke: 0.6pt + muted, fill: c-net, name: "net")
  content("net", text(8pt)[Internet])

  rect((0, 0), (2.0, 0.7), stroke: 0.5pt + muted, fill: c-lnk, name: "lan1")
  content("lan1", text(8pt)[10.1.1.0/24])
  rect((5.4, 0), (7.4, 0.7), stroke: 0.5pt + muted, fill: c-lnk, name: "lan2")
  content("lan2", text(8pt)[10.0.0.0/24])
  line("r1.south", "lan1.north", stroke: 0.6pt + muted)
  line("r2.south", "lan2.north", stroke: 0.6pt + muted)
  content((1.0, 1.35), text(7pt, fill: muted)[connected])
  content((6.4, 1.35), text(7pt, fill: muted)[connected])

  line("r1.east", "r2.west", stroke: 0.8pt + ink)
  content((3.7, my + 0.28), text(7.5pt, fill: muted)[OSPF / EIGRP])
  content((3.7, my - 0.32), text(7.5pt, fill: muted)[static default])
  line("r2.east", "net.west", stroke: 0.8pt + ink, mark: (end: ">"))
  content((8.44, my + 0.3), text(7.5pt, fill: muted)[default → ISP])
})

// Figure 4: IGP inside the AS, BGP between AS.
#let d-igp = cetz.canvas({
  import cetz.draw: *
  rect((0, 0), (6.2, 1.9), stroke: 0.7pt + muted, fill: c-app, radius: 6pt, name: "as1")
  content((3.1, 1.5), text(9pt, weight: "bold")[Enterprise  (AS 65010)])
  content((3.1, 0.75), align(center)[
    #text(8pt)[Interior gateway protocols (IGP)] \
    #text(8pt, fill: muted)[OSPF · EIGRP · IS-IS · RIP]
  ])
  rect((9.0, 0), (13.2, 1.9), stroke: 0.7pt + muted, fill: rgb("#f0f0f0"), radius: 6pt, name: "as2")
  content((11.1, 1.1), align(center)[
    #text(9pt, weight: "bold")[ISP / Internet] \ #text(8pt, fill: muted)[other AS]
  ])
  line("as1.east", "as2.west", stroke: 1pt + ink, mark: (start: ">", end: ">"))
  content((7.6, 1.35), text(8pt, weight: "bold")[BGP])
  content((7.6, 0.55), text(7pt, fill: muted)[exterior (EGP)])
})


= How data reaches a cloud web application

A student on Wi-Fi requests a web application on a remote cloud server. Each
layer of the stack wraps the data from the layer above in its own header
(encapsulation) on the way out, and the server unwraps them in reverse.

== (a) Path through the OSI and TCP/IP models

The seven OSI layers map onto the four TCP/IP layers by the colour groups in
@fig-stack. The same request is a stream of bytes at the top, a segment at the
transport layer, a packet at the network layer, and a frame of bits on the wire.

#figure(d-stack, caption: [OSI and TCP/IP layers, the protocol at each, and the direction of encapsulation.], kind: image, supplement: [Figure]) <fig-stack>

The request then crosses the network as shown in @fig-path:

+ DNS resolves the server's name to an IP address, normally over UDP port 53.
+ TCP opens a connection to port 443 with a three-way handshake, and TLS encrypts the exchange.
+ IP forwards the packet router by router. Each router rewrites the Layer-2 frame, so the MAC pair changes at every hop while the IP pair stays the same, NAT at the campus edge swaps the private source address for a public one.
+ The server unwraps the layers, TLS decrypts, and the web application reads the request. The reply retraces the path.

#figure(d-path, caption: [The request's path. MAC addresses change per hop, IP addresses hold end to end.], kind: image, supplement: [Figure]) <fig-path>

== (b) Protocols at each layer

The protocols sit at the layers shown in @fig-stack. Their roles:

- *HTTP / HTTPS*: carry the request and the page. HTTPS is HTTP wrapped in TLS.
- *DNS*: resolves the domain name to an IP address before the connection opens.
- *TLS*: authenticates the server by its certificate and encrypts every message.
- *TCP*: reliable, ordered, connection-oriented stream, used for the web request. *UDP*: connectionless and light, used for DNS and video conferencing.
- *IP*: logical addressing and hop-by-hop routing. *ARP*: maps the next-hop IP to a MAC on the local link.
- *Ethernet / Wi-Fi*: frame the data and deliver it by MAC address on one link.

= Routing across headquarters and branch offices

The company grows from four to twenty branches. A router forwards on the most
specific matching route (longest prefix), when two sources offer the same
network, it keeps the one with the lower administrative distance (AD).

== (a) Connected, static, default, and dynamic routes

@fig-routes shows all four on one branch-to-headquarters link.

#figure(d-routes, caption: [Route types on a branch-to-headquarters link.], kind: image, supplement: [Figure]) <fig-routes>

#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    [Route type], [How it enters the table], [AD], [Adapts?],
    [Connected], [Automatically, when an interface is addressed and up], [0], [No],
    [Static], [Configured by hand with a destination and next hop], [1], [No],
    [Default], [A static 0.0.0.0/0 for all unmatched traffic], [1], [No],
    [Dynamic], [Learned and updated by a routing protocol], [90--120], [Yes],
  ),
  caption: [The four kinds of routing-table entry],
)

Every router has connected routes for its own subnets. Small branches reach
headquarters over a static default route. As the network grows, a dynamic
protocol takes over so new subnets and failures propagate on their own.

== (b) Comparison of RIP, OSPF, EIGRP, IS-IS, and BGP

RIP, OSPF, EIGRP, and IS-IS are interior protocols (IGP) that run inside the
enterprise. BGP is the exterior protocol (EGP) that connects it to the Internet,
as in @fig-igp.

#figure(d-igp, caption: [Interior protocols run inside the autonomous system, BGP runs between systems.], kind: image, supplement: [Figure]) <fig-igp>

#pagebreak()
#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr),
    [Criterion], [RIP], [OSPF], [EIGRP], [IS-IS], [BGP],
    [Type], [Distance vector], [Link-state], [Advanced distance vector], [Link-state], [Path vector],
    [Metric / selection], [Hop count (max 15)], [Cost (from bandwidth)], [Bandwidth + delay], [Cost (default 10)], [Path attributes],
    [Convergence], [Slow], [Fast], [Very fast], [Fast], [Slow (policy)],
    [Scalability], [Low], [High], [High], [Very high], [Internet-scale],
    [IGP / EGP, AD], [IGP, 120], [IGP, 110], [IGP, 90 / 170], [IGP, 115], [EGP, 20 / 200],
    [Typical use], [Small / legacy nets], [Multi-vendor enterprise], [Cisco enterprise], [ISP backbones], [Between autonomous systems],
  ),
  caption: [Comparison of the five routing protocols]
)

For this network, RIP is ruled out by its 15-hop limit and slow convergence.
An all-Cisco estate can run EIGRP, a mixed-vendor estate runs OSPF, both using
areas or summarisation so twenty branches scale. IS-IS suits large providers
more than enterprises. BGP belongs at the Internet edge, and is needed once the
company takes links from more than one provider.
