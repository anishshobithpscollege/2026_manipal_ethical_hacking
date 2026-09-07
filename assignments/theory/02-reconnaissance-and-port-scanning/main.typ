#import "/template/lib.typ": *
#import "@preview/cetz:0.5.2"

#show: assignment.with(
  title: "Reconnaissance and Port-Scan Interpretation in an Authorised Assessment",
  number: "Assignment 02",
  kind: "Theory",
  date: datetime(year: 2026, month: 9, day: 7),
)

#show figure: set block(breakable: true)

#let ink = theme.ink
#let muted = theme.muted
#let c-app = rgb("#e8eef9")
#let c-trn = rgb("#e6f2ea")
#let c-net = rgb("#fdeaea")
#let c-lnk = rgb("#fbf1dd")
#let c-box = rgb("#f5f5f5")
#let c-out = rgb("#efefef")

// Figure 1: where the passive/active boundary falls.
#let d-recon = cetz.canvas({
  import cetz.draw: *
  let srcs = (
    "RDAP / WHOIS",
    "Certificate\nTransparency",
    "Search engines\n& documents",
    "Job ads &\ncode repos",
    "Shodan /\nCensys",
  )
  let bw = 2.3
  let gap = 0.25
  for i in range(5) {
    let x0 = i * (bw + gap)
    rect((x0, 3.5), (x0 + bw, 4.4), stroke: 0.5pt + muted, fill: c-app)
    content((x0 + bw / 2, 3.95), align(center, text(8pt)[#srcs.at(i).split("\n").join([\ ])]))
    line((x0 + bw / 2, 3.5), (x0 + bw / 2, 3.15), stroke: 0.5pt + muted)
  }
  let xr = 4 * (bw + gap) + bw
  let cx = xr / 2
  content((cx, 4.85), text(9pt, weight: "bold")[Records held by third parties])
  line((bw / 2, 3.15), (xr - bw / 2, 3.15), stroke: 0.5pt + muted)
  line((cx, 3.15), (cx, 2.75), stroke: 0.9pt + ink, mark: (end: ">"))

  rect((cx - 2.0, 1.95), (cx + 2.0, 2.75), stroke: 0.7pt + ink, fill: c-box)
  content((cx, 2.35), text(9pt, weight: "bold")[Assessment team])

  rect((cx - 2.0, 0.0), (cx + 2.0, 0.8), stroke: 0.6pt + muted, fill: c-net)
  content((cx, 0.4), text(9pt)[institution.example])
  line((cx, 1.95), (cx, 0.8), stroke: 0.9pt + ink, mark: (end: ">"))

  content((1.9, 1.38), align(center, text(7.5pt, fill: muted)[
    Passive: nothing is sent to \ the institution, so nothing \ is logged there
  ]))
  content((10.6, 1.38), align(center, text(7.5pt, fill: muted)[
    Active: DNS queries to the \ authoritative name server, port \
    and service scans, banner grabs
  ]))
})

// Figure 2: correlated attack-surface map, three lanes of differing confidence.
#let d-surface = cetz.canvas({
  import cetz.draw: *
  let rows = (0.0, 1.2, 2.4, 3.6, 4.8)
  let labels = ("Technology", "Service", "IP address", "DNS record", "Subdomain")
  let bh = 0.85
  for i in range(5) {
    content((-1.35, rows.at(i) + bh / 2), text(8pt, fill: muted)[#labels.at(i)])
  }
  let lanes = (0.0, 4.3, 8.6)
  let lw = 3.9

  let cell(li, ri, body, fl, dashed) = {
    let x0 = lanes.at(li)
    let st = if dashed { (paint: muted, thickness: 0.6pt, dash: "dashed") } else { 0.6pt + muted }
    rect((x0, rows.at(ri)), (x0 + lw, rows.at(ri) + bh), stroke: st, fill: fl)
    content((x0 + lw / 2, rows.at(ri) + bh / 2), align(center, text(7.5pt)[#body]))
  }
  let drop(li, ri) = {
    let x = lanes.at(li) + lw / 2
    line((x, rows.at(ri)), (x, rows.at(ri - 1) + bh), stroke: 0.6pt + muted, mark: (end: ">"))
  }

  let ox = lanes.at(1)
  rect((ox, 6.1), (ox + lw, 6.95), stroke: 0.8pt + ink, fill: c-box)
  content((ox + lw / 2, 6.525), text(9pt, weight: "bold")[Institution])
  for li in range(3) {
    line((ox + lw / 2, 6.1), (lanes.at(li) + lw / 2, rows.at(4) + bh), stroke: 0.6pt + muted, mark: (end: ">"))
  }

  cell(0, 4, [www.institution.example], c-app, false)
  cell(0, 3, [A record], c-lnk, false)
  cell(0, 2, [203.0.113.10 \ #text(7pt, fill: muted)[campus allocation]], c-trn, false)
  cell(0, 1, [443/tcp https], c-net, false)
  cell(0, 0, [nginx, PHP \ #text(7pt, fill: muted)[header and TLS certificate]], c-box, false)
  for r in (4, 3, 2, 1) { drop(0, r) }

  cell(1, 4, [institution.example \ #text(7pt, fill: muted)[apex, mail]], c-app, false)
  cell(1, 3, [MX records \ #text(7pt, fill: muted)[TXT: SPF, DMARC]], c-lnk, false)
  cell(1, 2, [provider range \ #text(7pt, fill: muted)[RDAP: SaaS operator]], c-out, false)
  cell(1, 1, [25/tcp smtp], c-out, false)
  cell(1, 0, [hosted mail tenant \ #text(7pt, fill: muted)[third party, out of scope]], c-out, false)
  for r in (4, 3, 2, 1) { drop(1, r) }

  cell(2, 4, [legacy-portal. \ institution.example], c-out, true)
  cell(2, 3, [no A record returned], c-out, true)
  let lx = lanes.at(2)
  rect((lx, rows.at(0)), (lx + lw, rows.at(2) + bh), stroke: (paint: muted, thickness: 0.6pt, dash: "dashed"), fill: c-out)
  content((lx + lw / 2, (rows.at(0) + rows.at(2) + bh) / 2), align(center, text(7.5pt)[
    Candidate only \
    #text(7pt, fill: muted)[a certificate once existed for \ this name; no live host was \ observed, so no asset is drawn]
  ]))
  drop(2, 4)
})

// Figure 3: scanning pipeline with its feedback path.
#let d-pipeline = cetz.canvas({
  import cetz.draw: *
  let stages = (
    ("1. Scope", "written authorisation\ntarget list, time window"),
    ("2. Host discovery", "which addresses respond\nARP, ICMP, TCP probes"),
    ("3. Port scanning", "full TCP range, then UDP\na state for every port"),
    ("4. Service detection", "probe responses, banners\nversion strings"),
  )
  let bw = 3.35
  let gap = 0.4
  for i in range(4) {
    let x0 = i * (bw + gap)
    rect((x0, 1.0), (x0 + bw, 2.35), stroke: 0.6pt + muted, fill: if i == 0 { c-box } else { c-app })
    content((x0 + bw / 2, 2.02), text(8.5pt, weight: "bold")[#stages.at(i).at(0)])
    content((x0 + bw / 2, 1.45), align(center, text(7pt, fill: muted)[
      #stages.at(i).at(1).split("\n").join([\ ])
    ]))
    if i < 3 {
      line((x0 + bw, 1.675), (x0 + bw + gap, 1.675), stroke: 0.9pt + ink, mark: (end: ">"))
    }
  }
  let c3 = 2 * (bw + gap) + bw / 2
  let c4 = 3 * (bw + gap) + bw / 2
  line((c4, 1.0), (c4, 0.42), (c3, 0.42), (c3, 1.0), stroke: 0.8pt + muted, mark: (end: ">"))
  content(((c3 + c4) / 2, 0.05), text(7.5pt, fill: muted)[re-probe filtered and open|filtered ports with a different technique])
})

// Figure 4: the packet exchange behind each state.
#let d-states = cetz.canvas({
  import cetz.draw: *
  let dsh = (paint: muted, thickness: 0.7pt, dash: "dashed")
  let panel(ox, oy, title, note, arrows) = {
    let w = 3.6
    content((ox + w / 2, oy + 2.25), text(9pt, weight: "bold")[#title])
    content((ox - 0.35, oy + 1.85), text(7.5pt, fill: muted)[Nmap])
    content((ox + w + 0.35, oy + 1.85), text(7.5pt, fill: muted)[Target])
    line((ox, oy + 1.62), (ox, oy + 0.32), stroke: 0.4pt + muted)
    line((ox + w, oy + 1.62), (ox + w, oy + 0.32), stroke: 0.4pt + muted)
    for a in arrows {
      let (dy, dir, lbl, dashed) = a
      let y = oy + dy
      let st = if dashed { dsh } else { 0.8pt + ink }
      if dir == 1 {
        line((ox, y), (ox + w, y), stroke: st, mark: (end: ">"))
      } else {
        line((ox + w, y), (ox, y), stroke: st, mark: (end: ">"))
      }
      content((ox + w / 2, y + 0.19), text(7.5pt)[#lbl])
    }
    content((ox + w / 2, oy - 0.02), text(7.5pt, fill: muted)[#note])
  }
  panel(0.6, 3.2, "open", "80/tcp, 443/tcp, 22/tcp", (
    (1.45, 1, [SYN], false), (1.0, -1, [SYN/ACK], false), (0.55, 1, [RST], false),
  ))
  panel(7.2, 3.2, "closed", "65000/tcp", (
    (1.45, 1, [SYN], false), (1.0, -1, [RST/ACK], false),
  ))
  panel(0.6, 0.0, "filtered", "445/tcp", (
    (1.45, 1, [SYN, then retries], false), (1.0, -1, [nothing, or ICMP type 3], true),
  ))
  panel(7.2, 0.0, "open|filtered", "53/udp", (
    (1.45, 1, [UDP probe], false), (1.0, -1, [nothing], true),
  ))
})


= Footprinting an institution from its domain name

The team starts with one input, the institution's primary domain name, and a
signed authorisation. Every other fact about the estate has to be derived and
then checked. The work is ordered so that the cheapest and least visible sources
are exhausted before anything is sent to the institution's own systems.

== (a) Passive and active information gathering

*Passive* gathering reads records that third parties already hold. The
institution's systems receive no traffic and its logs record nothing.
*Active* gathering sends packets to the target and is visible to it.
@fig-recon shows where the line falls.

#figure(d-recon, caption: [Passive sources feed the team without touching the institution; active techniques cross into its own systems.], kind: image, supplement: [Figure]) <fig-recon>

The boundary is not always where it appears. A DNS lookup answered from a public
resolver's cache is passive, but the same lookup for a name the resolver has not
cached is forwarded to the institution's authoritative name server and is
therefore active. Certificate Transparency and Shodan are passive because the
data was collected by someone else at an earlier time, not because the subject
matter is harmless.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    [Mode], [Techniques], [Visibility to the institution],
    [Passive],
    [RDAP and WHOIS lookups, Certificate Transparency log queries, search-engine
    operators, cached DNS answers, public document metadata, job advertisements,
    public code repositories, Shodan and Censys records, historical archives],
    [None. The records queried are held by registries, log operators, search
    engines and scanning services],
    [Active],
    [Queries to the authoritative name servers, attempted zone transfers, host
    discovery, port scanning, service and version detection, banner grabbing,
    HTTP requests, TLS certificate retrieval from the live host],
    [Recorded in DNS query logs, firewall and IDS logs, web access logs and
    service logs],
  ),
  caption: [Techniques by gathering mode],
)

== (b) What each source contributes

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    [Source], [What it yields], [Limitation],
    [RDAP / WHOIS],
    [Registrant organisation, registrar, delegated name servers, registration and
    expiry dates, abuse contact. RDAP also covers IP allocations, which names the
    owner of a netblock],
    [Registrant contact details are usually redacted. RDAP became the definitive
    source for gTLD registration data on 28 January 2025, when the WHOIS service
    requirement was sunset, so port-43 WHOIS may return nothing],
    [DNS records],
    [A and AAAA give hosts, NS gives the DNS operator, MX gives the mail path,
    CNAME reveals SaaS platforms behind a branded name, TXT carries SPF and DMARC
    and so names every third party authorised to send mail],
    [Only names that are guessed, or learned elsewhere, can be resolved. There is
    no way to list a zone unless AXFR is misconfigured],
    [Certificate Transparency],
    [Every certificate issued by a publicly trusted CA is logged under RFC 6962.
    A search for `%.institution.example` returns subdomains that were never
    published in DNS, along with issue dates and the full SAN list],
    [A log entry records an issuance, not a running host. Entries persist after
    the host is decommissioned],
    [Search engines],
    [`site:` narrows to the domain and surfaces indexed subdomains;
    `filetype:pdf` and similar find published documents; cached error pages and
    directory listings expose paths and software],
    [The index is stale and partial, and reflects what the crawler was allowed to
    see],
    [Public documents],
    [Document metadata carries author names, internal file paths, printer and
    server names, and the software version used to produce the file. Policies and
    tender documents name products in use],
    [Metadata is often stripped on publication, and describes the machine that
    produced the file rather than the estate],
    [Job advertisements],
    [A vacancy that asks for experience with a named firewall, learning
    management system or database is an inventory of the products in use, and the
    seniority of the post indicates the size of the deployment],
    [Advertisements describe a wanted skill set, which may include products being
    introduced or retired],
    [Public code repositories],
    [Staff and student repositories hold configuration files, CI pipeline
    definitions naming internal hosts, connection strings and occasionally
    credentials. Commit history retains values deleted from the current tree],
    [Attribution to the institution has to be established before anything found
    is treated as its asset],
    [Shodan / Censys],
    [Banners, HTTP headers, certificate contents and observed ports for hosts
    already scanned from the Internet. Searching by certificate subject or
    organisation finds hosts whose DNS names were never published],
    [Results carry the date of the last scan, which may be weeks old, and the
    service may since have changed or moved],
  ),
  caption: [Reconnaissance sources and what each is good for],
)

== (c) Correlating and validating findings

A source produces a *candidate*, not an asset. A candidate is promoted only when
its existence and its ownership are both established. The sequence:

+ Record every candidate in one list with the source that produced it, the value,
  and the time it was retrieved.
+ Resolve each candidate name for A, AAAA and CNAME records. Names that do not
  resolve are held as historical rather than discarded, because a name may return
  later or point at a resource someone else now controls.
+ Group the resolved addresses into netblocks and run an RDAP query on each block.
  This separates addresses inside the institution's own allocation from addresses
  belonging to a cloud or SaaS provider.
+ Confirm identity on the live host. The TLS certificate subject and SAN list, the
  HTTP response headers, and the page content each tie an address back to the
  institution. A certificate naming the institution on an address inside its own
  allocation is strong evidence; the same certificate on a shared CDN address is
  weak, because the address serves many customers.
+ Treat a technology named in a job advertisement or a document as a hypothesis.
  It becomes a finding only when a banner, header or protocol behaviour on a live
  host agrees with it.
+ Build the mail picture from three records together: the MX names, the SPF TXT
  record listing authorised senders, and the DMARC policy. Resolving the MX names
  and running RDAP on the result shows whether mail is handled on campus or by a
  provider.
+ Mark each entry confirmed, probable or unconfirmed, and keep the evidence
  against it. The confidence level is what allows the report to be defended.

The result is @fig-surface, in which the same six-layer structure is applied to
assets of three different confidence levels.

#figure(d-surface, caption: [Attack-surface map. Left: a confirmed self-hosted asset. Centre: an asset resolving to a third-party provider. Right: a candidate from Certificate Transparency that no live observation supports.], kind: image, supplement: [Figure]) <fig-surface>

== (d) Why two particular findings prove nothing on their own

*The Certificate Transparency entry.* A CT log entry is a record that a CA issued
a certificate covering `legacy-portal.institution.example` on a given date. It
says nothing about whether a host answers to that name now. Certificates are
issued for staging systems, for planned services that were never built, for hosts
since decommissioned, and as multi-SAN or wildcard certificates covering names
that were only ever placeholders. Three outcomes are possible on validation: the
name does not resolve, in which case it stays a historical candidate; it resolves
to an address the institution no longer controls, which is a dangling-record
finding in its own right and needs care because that address belongs to someone
else; or it resolves to a live host, which is then confirmed by comparing the
certificate the host actually serves against the logged one.

*The VPN technology in the old document.* A document states what was true when it
was written. The document may be a proposal rather than a record of a deployment,
the product may have been replaced, and the version certainly will have moved.
Reporting a CVE against a version taken from a document produces a finding with
no observation behind it. Validation means going to the live endpoint: the
service banner, the TLS certificate, the login page fingerprint, or the response
to a protocol-specific probe.

Both cases follow one principle. Passive sources describe the past. Only an
observation of the running system establishes the present state, and that
observation has to fall inside the authorised scope.

== (e) Attack-surface diagram

See @fig-surface. Each column is one chain from the organisation down through
subdomain, DNS record, address, service and technology. Solid boxes are confirmed
by a live observation, the grey column is confirmed but hosted by a third party,
and the dashed column is a candidate that the map records without treating as an
asset.

== (f) Ethical, legal and scope questions raised by third-party hosting

Authorisation is granted per system, not per name. The institution can authorise
testing of infrastructure it owns or controls. It cannot authorise testing of a
platform that a provider owns and operates for many customers, because the
provider's other tenants never consented and their data sits on the same
infrastructure. A subdomain that resolves into a SaaS provider's address range
is therefore out of scope by default and stays there until the client supplies
written confirmation of what it controls.

Providers publish their own rules and those rules bind the tester independently
of the client's authorisation. Amazon Web Services, for example, permits
customers to run port scanning, vulnerability scanning and exploitation against
a listed set of services without prior approval, but requires an approved
Simulated Event form for command-and-control testing and denial-of-service
simulation, and prohibits activities such as DNS zone walking through Route 53
and request flooding. Testing outside those rules breaches the provider's
acceptable use policy even when the client asked for it.

Unauthorised access carries statutory liability. Under the Information Technology
Act, 2000, section 43 imposes civil liability for accessing a computer system
without the permission of the person in charge, with compensation up to one crore
rupees. Section 66 makes the same acts a criminal offence when done dishonestly
or fraudulently, punishable with imprisonment up to three years, a fine up to
five lakh rupees, or both. A scan that strays onto an address the client does not
in fact control is exposed to both provisions, and the tester's intent does not
supply the missing consent.

Reconnaissance also collects personal data. Staff names, e-mail addresses and
roles taken from documents, job advertisements and repositories fall under the
Digital Personal Data Protection Act, 2023. The engagement should collect only
what the assessment needs, store it under the same controls as the rest of the
evidence, and destroy it when the report is delivered.

Passive work is unaffected by any of this. Reading CT logs, RDAP records and
Shodan data about a third-party-hosted asset touches nobody's systems and stays
permissible. The constraint applies to active probing, which is why the scope
document should carry three lists rather than two: in scope, out of scope, and
awaiting clarification.

#pagebreak()

= Interpreting an Nmap scan of an isolated laboratory host

== (a) The four port states

Nmap reports a state per port, and the state describes the response Nmap
received, not the condition of the host. @fig-states shows the exchange behind
each of the four states in the scan output.

#figure(d-states, caption: [The packet exchange that produces each state. Dashed arrows mark an absent or negative response.], kind: image, supplement: [Figure]) <fig-states>

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    [State], [What it proves], [What it does not prove],
    [open],
    [An application accepted the probe: a SYN/ACK for a TCP SYN scan, or a
    protocol response for UDP. The port is reachable from the scanning host and
    something is listening at scan time],
    [Which software is listening, which version, whether the service is meant to
    be reachable, or that any weakness exists. The service name shown against the
    port comes from Nmap's port-number table unless version detection was run],
    [closed],
    [The probe reached the host and a RST came back. The host is up and the path
    to that port carries no filter. A closed port is a useful control: it shows
    the network is not dropping everything],
    [That nothing ever listens there. The service may be stopped, bound to a
    different interface, or started on a schedule],
    [filtered],
    [Something dropped the probe. Either no reply arrived across repeated
    attempts, or an ICMP unreachable was returned],
    [Whether a service exists behind the filter, and where the filter sits. It may
    be the host firewall, a device in front of the host, or a rule on the
    scanner's own network],
    [open|filtered],
    [No response of any kind arrived, so the two states cannot be separated. On
    UDP this is the common outcome, because a service that answers only
    well-formed protocol requests ignores a generic probe],
    [Anything about the service. It records only that no negative response, such
    as an ICMP port-unreachable, came back],
  ),
  caption: [The four states in the scan output],
)

Read against 192.168.56.20: ports 22, 80 and 443 answered and are open; 65000
returned a RST and is closed, which confirms the host is reachable and not behind
a blanket drop rule; 445 is filtered, so SMB may or may not be running behind a
rule that hides it; and 53/udp is undetermined and needs a real DNS query to
settle.

== (b) Methodology from host discovery to service detection

@fig-pipeline sets out the order. Each stage narrows the target set for the next,
which keeps the traffic volume down and the results interpretable.

#figure(d-pipeline, caption: [Scanning pipeline. Ports left ambiguous by stage 3 are returned to it with a different probe.], kind: image, supplement: [Figure]) <fig-pipeline>

*Scope.* Confirm the authorised address range, the permitted window and the
prohibited techniques in writing before any packet is sent. Capture the scan
traffic so the engagement record shows what was actually done.

*Host discovery.* Establish which addresses answer, using `nmap -sn` across the
range. On the local segment this uses ARP, which cannot be filtered by a host
firewall and is reliable. Across a router Nmap falls back to ICMP echo, TCP SYN
to 443, TCP ACK to 80 and an ICMP timestamp request. Where ICMP is filtered,
`-Pn` skips discovery and treats every address as live, at the cost of a much
longer scan.

*Port scanning.* Scan the full TCP range with a SYN scan before assuming the
common ports are the whole picture, since 65000 in this output shows the range
matters. Follow with UDP against the top ports only, because UDP scanning is slow
and depends on ICMP rate limits. Repeat the scan later to catch services that
were not running the first time.

*Service detection.* Run version detection against the ports found open, rather
than the whole range. Nmap sends protocol-specific probes and matches the
responses against its signature database, which yields a product and often a
version and operating system. Ports left filtered or open|filtered go back to the
port-scanning stage with a different technique: an ACK scan to classify the
filter, a source port of 53 or 80 to test naive rules, or a protocol-specific
UDP payload instead of an empty probe.

*Correlation.* Cross-check the version string against the host's other evidence
before it is written down, then proceed to the validation in part (e).

== (c) What DNS, SSH and HTTP/HTTPS add

*DNS on 53/udp.* If the port is open, a query settles the state that the scan
could not. The server's own configuration is then testable: a `version.bind`
CHAOS TXT query returns the implementation string on servers that have not
suppressed it, reverse lookups across the laboratory range return host names, and
an attempted zone transfer returns the full contents of a zone where AXFR is
left open. Recursion available to an arbitrary client is itself a finding,
because the server can be used to amplify traffic at a third party.

*SSH on 22/tcp.* The banner is sent before authentication and identifies the
protocol version and usually the exact software build, including the
distribution's package suffix, which in turn indicates the operating system. The
key exchange offers the supported algorithm list, which narrows the version
further. The host key fingerprint identifies the host, and a fingerprint seen on
two addresses shows they are the same machine or were cloned from one image.

*HTTP and HTTPS on 80 and 443.* The `Server` and `X-Powered-By` headers name the
software; cookie names indicate the application framework; redirects, `robots.txt`
and the shape of the error pages narrow the application further. HTTPS adds the
certificate, whose subject and SAN list give the host's real names and often
other names served by the same system, and whose issue date shows when the
deployment was last touched. Because a single address can serve different
applications by `Host` header, the certificate is also what tells the tester how
many applications are behind the one open port.

== (d) Why an open port is not a vulnerability

The statement fails on three separate grounds.

The first is a category error. "Open" is a statement about reachability, produced
by a TCP handshake at the transport layer. A vulnerability is a property of the
software behind the port and of how it is configured. The scan observed the
transport and never reached the application.

The second is that the scan does not establish what is listening. Port 443 is a
convention, and the label `https` in the output is the port number looked up in
Nmap's services file, not something the host said about itself. Without version
detection there is no evidence of a web server at all.

The third is that even a correctly identified, out-of-date web server is
vulnerable only if the flawed code path is present and reachable, the affected
feature is enabled, the fix has not been backported into the installed package,
and no control in front of the service blocks the request. An open port is an
entry point that has to be examined. Reachability is a precondition for
exploitation, not evidence of it.

== (e) Validating a version-to-CVE match before reporting

+ *Confirm the version string.* Banners are configurable and are sometimes set to
  mislead. Corroborate with a second independent signal: another header, an error
  page, a protocol behaviour that changed between releases, or the package
  version read on the host where access is available.
+ *Check for backported fixes.* Enterprise distributions apply the upstream
  security fix to the older package and keep the version number unchanged, which
  is documented practice at Red Hat. A scanner that matches on the upstream
  version alone reports a patched system as vulnerable. The correct check
  compares the full package version and release against the distribution's own
  security data rather than the upstream number.
+ *Read the applicability conditions.* Most CVE records are conditional on a
  module being compiled in, a non-default option being enabled, a particular
  platform, or a specific configuration. The vendor advisory states these
  conditions; the CVE summary and the base score usually do not.
+ *Identify compensating controls.* A reverse proxy that normalises requests, a
  network filter, a mandatory access control policy, or the service running
  unprivileged inside a container can each make an otherwise present flaw
  unreachable.
+ *Score for this environment.* The CVSS base score describes the flaw in the
  abstract. The Environmental metric group adjusts it for the deployment, which
  is what separates an internet-facing host from one reachable only through an
  authenticated VPN. CVSS v4.0 was published by FIRST on 1 November 2023 and adds
  a Safety metric to that group.
+ *Attempt a safe confirmation.* Within the rules of engagement, run a
  non-destructive check that distinguishes vulnerable from patched. Proof-of-concept code that crashes the service or denies access to it needs separate
  written permission.
+ *Report the confidence honestly.* Distinguish confirmed and demonstrated,
  present but not exploited, potential on a version match alone, and false
  positive, and record the evidence behind each. A version match reported as a
  confirmed vulnerability is a defect in the report.

== (f) Wireshark as packet-level evidence for the scan

Nmap's state column is a conclusion. A capture taken on the scanning interface at
the same time is the evidence for it, and the two are compared afterwards.

Start the capture before the scan, with a capture filter restricted to the target
so the file stays small, then apply display filters to isolate each class of
response. Each filter below is combined with `ip.addr == 192.168.56.20`.

#figure(
  table(
    columns: (7.2cm, 1fr),
    [Display filter], [What it shows],
    [#text(8.5pt)[`tcp.flags.syn == 1 && tcp.flags.ack == 0`]],
    [Every probe Nmap sent, and the retransmissions to ports that did not answer],
    [#text(8.5pt)[`tcp.flags.syn == 1 && tcp.flags.ack == 1`]],
    [One SYN/ACK per open port. The number of distinct destination ports here
    should equal the number Nmap reported open],
    [#text(8.5pt)[`tcp.flags.reset == 1`]],
    [The RST/ACK responses behind every closed port, including 65000],
    [#text(8.5pt)[`icmp.type == 3`]],
    [Unreachable messages. Code 13, administratively prohibited, is a filter
    identifying itself; silence plus retransmissions is a silent drop, which is
    what 445 shows],
  ),
  caption: [Display filters that map onto the reported states],
)

Three points follow. Port 65000 appears as exactly one SYN out and one RST/ACK
back, which is the closed state in full. Port 445 appears as a SYN and its
retransmissions with no reply, which is the filtered state and also explains why
filtered ports make a scan slow. Statistics then Conversations lists every port
the scan touched, and comparing that list against the Nmap output confirms the
scan did what the report claims, stayed inside the authorised address range, and
ran inside the agreed window.
