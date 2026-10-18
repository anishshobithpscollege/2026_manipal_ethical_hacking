#import "/template/lib.typ": *
#import "@preview/cetz:0.5.2"

#show: assignment.with(
  title: "Social Engineering Attacks: Importance and Countermeasures",
  number: "Assignment 03",
  kind: "Theory",
  date: datetime(year: 2026, month: 10, day: 18),
)

#show figure: set block(breakable: true)

#let ink = theme.ink
#let muted = theme.muted
#let c-app = rgb("#e8eef9")
#let c-trn = rgb("#e6f2ea")
#let c-net = rgb("#fdeaea")
#let c-lnk = rgb("#fbf1dd")
#let c-box = rgb("#f5f5f5")

// Figure 1: the stages of an attack and the control that blocks each stage.
#let d-chain = cetz.canvas({
  import cetz.draw: *
  let atk = (
    ("1. Research", "reads public pages,\njob ads, social media"),
    ("2. Pretext", "chooses a role: help desk,\nmanager, supplier"),
    ("3. Request", "asks for a password,\ncode, click or payment"),
    ("4. Access", "uses the login, runs the\nmalware, takes the money"),
    ("5. Spread", "moves to other systems\nor repeats on new targets"),
  )
  let ctl = (
    "Limit public detail\nabout staff and systems",
    "Training and a list\nof known contacts",
    "Call back on a known\nnumber, second approver,\nmail filter",
    "Phishing-resistant MFA,\nleast privilege",
    "Logs, alerts, fast\nreport and response",
  )
  let bw = 2.85
  let gap = 0.4
  for i in range(5) {
    let x0 = i * (bw + gap)
    rect((x0, 2.6), (x0 + bw, 4.0), stroke: 0.6pt + muted, fill: c-net)
    content((x0 + bw / 2, 3.68), text(8.5pt, weight: "bold")[#atk.at(i).at(0)])
    content((x0 + bw / 2, 3.08), align(center, text(7pt, fill: muted)[
      #atk.at(i).at(1).split("\n").join([\ ])
    ]))
    if i < 4 {
      line((x0 + bw, 3.3), (x0 + bw + gap, 3.3), stroke: 0.9pt + ink, mark: (end: ">"))
    }
    rect((x0, 0.2), (x0 + bw, 1.5), stroke: 0.6pt + muted, fill: c-trn)
    content((x0 + bw / 2, 0.85), align(center, text(7pt)[
      #ctl.at(i).split("\n").join([\ ])
    ]))
    line((x0 + bw / 2, 1.5), (x0 + bw / 2, 2.6), stroke: 0.9pt + ink, mark: (end: ">"))
  }
  content((7.925, -0.25), text(7.5pt, fill: muted)[
    Top row: what the attacker does. Bottom row: the control that blocks that stage.
  ])
})

// Figure 2: shares of breaches in the Verizon 2026 DBIR.
#let d-bars = cetz.canvas({
  import cetz.draw: *
  let rows = (
    ("Human element present", 62),
    ("Credential abuse at any stage", 39),
    ("Social Engineering pattern", 16),
    ("Phishing as initial access", 16),
    ("Pretexting as initial access", 6),
  )
  let s = 0.13
  let x0 = 4.8
  let bh = 0.55
  let gp = 0.35
  let n = rows.len()
  let top = n * (bh + gp) - gp
  for t in (0, 20, 40, 60) {
    line((x0 + t * s, -0.1), (x0 + t * s, top + 0.1), stroke: (paint: theme.rule, thickness: 0.4pt))
    content((x0 + t * s, -0.4), text(7.5pt, fill: muted)[#t%])
  }
  for i in range(n) {
    let y = (n - 1 - i) * (bh + gp)
    let (lbl, v) = rows.at(i)
    content((x0 - 0.2, y + bh / 2), anchor: "east", text(8pt)[#lbl])
    rect((x0, y), (x0 + v * s, y + bh), stroke: 0.5pt + muted, fill: if i == 0 { c-app.darken(10%) } else { c-app })
    content((x0 + v * s + 0.15, y + bh / 2), anchor: "west", text(8pt, weight: "bold")[#v%])
  }
})


= Social engineering attacks in the cyber world

== (a) What a social engineering attack is

*Social engineering* is the act of tricking a person. The attacker uses the trick
to get sensitive information, to get unauthorised access, or to commit fraud (NIST
SP 1800-21B). The attacker first builds the trust of the person. Then the attacker
asks for the action. The target is a person, not a computer.

The attack works because it uses normal human behaviour. People obey a person with
authority. People want to help. People act fast when they think that they can lose
something. A firewall does not check these things. The attacker needs only one
person who says yes.

@tbl-types lists the common types. @fig-chain shows the usual stages of an attack
and the control that blocks each stage. Part (c) explains the controls.

#figure(
  table(
    columns: (3.3cm, 3.4cm, 1fr),
    [Type], [Channel], [How the attack works],
    [Phishing],
    [Email, text message, web page],
    [The attacker sends a message that looks like it comes from a known company. The
    message asks for personal data, a payment or login details. Smishing uses text
    messages. Vishing uses phone calls],
    [Spear phishing],
    [Email],
    [The message uses facts about one person or one team, so it looks real],
    [Pretexting],
    [Voice, email, text message],
    [The attacker invents a scenario to gain trust. The attacker then asks the target
    to do an action. An example is a caller who claims to be from the IT help
    desk],
    [Business email compromise (BEC)],
    [Email, phone, video call],
    [The attacker acts as an executive or a supplier. The attacker asks for a payment
    or a change of bank details],
    [SIM swap],
    [Mobile network],
    [The attacker convinces the mobile carrier to move the phone number of the victim
    to a SIM card that the attacker controls. The attacker then receives the SMS
    codes],
    [Deepfake impersonation],
    [Video, voice],
    [The attacker uses an AI-made voice or video of a known person],
    [Baiting],
    [USB drive, free download],
    [The attacker leaves an item that holds malware and waits for a person to use it],
    [Tailgating],
    [Physical entry],
    [The attacker follows an authorised person through a controlled door],
  ),
  caption: [Common types of social engineering attack],
) <tbl-types>

#figure(d-chain, caption: [The stages of a social engineering attack. Each stage has a control that blocks it.], kind: image, supplement: [Figure]) <fig-chain>

== (b) Importance of social engineering attacks

*They are common.* The Verizon 2026 Data Breach Investigations Report (DBIR)
found the human element in 62% of breaches. The figure was 60% in the year before.
Social Engineering was the third most common breach pattern, at 16% of all
breaches. Phishing was the first step in 16% of breaches, and pretexting in 6%.
@fig-dbir shows these shares. The FBI Internet Crime Complaint Center (IC3) shows
the same trend from the side of the victim. In 2025, phishing and spoofing was the
most reported crime type, with 191,561 of 1,008,597 complaints.

#figure(d-bars, caption: [Shares of breaches in the Verizon 2026 DBIR. Credential abuse is counted at any stage of a breach. The other values are counted for the first step or for the pattern.], kind: image, supplement: [Figure]) <fig-dbir>

*They cause large financial loss.* IC3 recorded total reported losses of
\$20.877 billion in the United States in 2025. This is 26% more than in 2024.
Business email compromise caused \$3.05 billion of the loss, in 24,768 complaints.
In 2024 the figures were \$2.77 billion and 21,442 complaints. Losses from
phishing and spoofing complaints rose from \$70.0 million to \$215.8 million in
one year. These figures count only the complaints that victims reported.

*They pass technical controls.* The attacker asks the person for the thing that the
control protects. A password, a VPN and MFA all depend on the person who uses
them. @tbl-cases shows three cases. In each case, the attacker used a person to
pass a control that was in place.

#figure(
  table(
    columns: (3cm, 1fr, 4.4cm),
    [Case], [What the attacker did], [Result],
    [Twitter, July 2020 (NYDFS report)],
    [Called employees and said that the call was from the IT help desk about VPN
    faults. Sent them to a copy of the VPN login page. Used the stolen password on
    the real page at the same time. Some employees approved the MFA prompt that
    followed],
    [130 accounts taken over. More than \$118,000 in bitcoin stolen. The company had
    no chief information security officer since December 2019],
    [Scattered Spider, 2023 (CISA advisory AA23-320A)],
    [Sent text messages and made calls as IT staff to get credentials. Called help
    desks as employees. Asked for password resets and a move of the MFA token to a
    device that the group controlled],
    [Account takeover in single sign-on systems],
    [Arup, January 2024],
    [A finance employee in Hong Kong joined a video call with fake versions of the
    chief financial officer and other staff. The call followed a message that
    asked for a secret transaction],
    [15 transfers worth HK\$200 million, about US\$25 million. Arup stated that its
    systems were not compromised],
  ),
  caption: [Three cases of social engineering],
) <tbl-cases>

*They start larger attacks.* One tricked person gives the attacker a first point of
entry. DBIR 2026 reports that pretexting is now a more common first step in
ransomware and extortion attacks. DBIR 2026 also finds credential abuse at some
stage in 39% of breaches. In the Twitter case, the first account that the
attackers took had no access to the internal account tools. The attackers used it to
learn about the internal systems. They then targeted the employees who had that
access.

*They are harder to detect now.* AI tools make a fake voice or a fake video
cheap. The Arup case in @tbl-cases is an example. DBIR 2026 also reports that, in
simulations, the median click rate on mobile-centric vectors is 40% higher than on
email. Voice and text messages are examples of these vectors. A mail filter does not
see a phone call.

*They are crimes.* Section 66C of the Information Technology Act, 2000 punishes the
fraudulent use of the password or other unique identification feature of another
person. Section 66D punishes cheating by personation with a computer resource.
Each section carries imprisonment up to three years and a fine up to one lakh
rupees.

== (c) How to overcome social engineering attacks

No single control stops a social engineering attack, because each attack uses a
person. An organisation needs four layers: people, process, technology and
response. @tbl-controls lists the controls. Each control blocks a stage in
@fig-chain.

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    [Layer], [Control], [What it stops], [Limit],
    [People],
    [Awareness training with phishing, smishing and vishing simulations],
    [Clicks and disclosure of data],
    [Click rates do not reach zero. Repeat the training],
    [People],
    [Role-based training for help desk, finance and executive staff],
    [Pretexting and BEC],
    [Staff need written rules that they can apply],
    [Process],
    [Check a payment request and any change of bank details with a call to a number
    from the company directory. Add a second approver],
    [BEC and deepfake requests],
    [Slows an urgent payment. Staff must be free to refuse],
    [Process],
    [Check the identity of the caller before a password or MFA reset at the help desk],
    [Help desk impersonation],
    [Needs a second channel, for example a call back on the number on file],
    [Technology],
    [Phishing-resistant MFA (FIDO/WebAuthn or PKI-based)],
    [Credential phishing, push bombing, SIM swap],
    [Needs hardware or platform support. Some old systems do not accept it],
    [Technology],
    [SPF, DKIM and DMARC with a mail gateway and URL filter],
    [Forged sender addresses and known bad links],
    [Does not stop look-alike domains, phone calls or text messages],
    [Technology],
    [Least privilege, logs and alerts],
    [Spread after the first account is lost],
    [Detects the attacker after the first step],
    [Response],
    [A simple way to report, with no blame],
    [Delay between the first step and the response],
    [Needs a fast reaction from the security team],
  ),
  caption: [Controls against social engineering by layer],
) <tbl-controls>

*People.* NIST SP 800-50 Rev. 1 describes a learning programme that includes
phishing, smishing and vishing simulations. It gives one measure: the number of
staff who received a test email and reported it. Train each role for its own risk.
DBIR 2026 states that training against pretexting needs rules that fit the work of
each group, for example the help desk and customer support. Make it easy to report
a suspect message or call. At Twitter, some employees reported the calls to the
internal fraud team, but at least one employee believed the caller.

*Process.* Each case in @tbl-cases had a point where one person acted alone. At
Twitter, employees approved the MFA prompt. In the Scattered Spider cases, the help
desk reset the credential. At Arup, one finance employee made the transfers. A
process rule gives a second person or a second channel at each of these points.
This is a recommendation that follows from the cases.

*Technology.* CISA (October 2022) names FIDO/WebAuthn and PKI-based MFA as the
strongest forms of MFA. CISA states that SMS and voice codes are vulnerable to
phishing, SS7 attacks and SIM swap. It also states that push notifications without
number matching are vulnerable to push bombing. NIST SP 800-63B-4 defines
phishing resistance as protection that does not depend on the vigilance of the user.
It states that codes entered by hand are not phishing-resistant. At assurance level
AAL3, the authenticator must have phishing resistance. At level AAL2, the verifier
must offer a phishing-resistant option. A phishing-resistant authenticator does not
give a valid response to a copy of the login page. This blocks the credential relay
that the attackers used at Twitter.

*Response.* Speed decides the result. A bank can sometimes hold a payment if the
victim reports it quickly. In India, report a financial cyber fraud to the helpline
1930 and on the National Cyber Crime Reporting Portal (cybercrime.gov.in). An
organisation must report the incidents listed in the CERT-In Directions of
28 April 2022 within 6 hours.

== (d) Procedure for a suspicious request

An employee uses these steps when a message, a call or a video call asks for a
password, a code, a payment or a click.

+ Stop. Do not click, open, pay or reply.
+ Look at the sender address, the link target and the reason for the hurry.
+ Contact the sender on a known number or channel. Do not use the number in the
  message.
+ Do not give a password, a one-time code or an MFA approval to a caller.
+ Report the message with the report button or to the security team.
+ If a click or a payment already happened, tell the security team at once. Change the
  password. Call the bank for a payment.

== (e) Testing the controls in an authorised assessment

An organisation can measure its real exposure with a social engineering test inside
an authorised assessment. The scope document lists the allowed methods, for
example phishing email, phone call or site visit. It also lists the target groups,
the time window and the stop conditions.

The test page records that a login happened. It does not keep the password. The
report gives results by group, not by name. The report shows the report rate as well
as the click rate, because NIST SP 800-50 Rev. 1 uses the report rate as a
measure. Staff names, email addresses and phone numbers are personal data under the
Digital Personal Data Protection Act, 2023. Collect only what the test needs and
delete it after the report.
