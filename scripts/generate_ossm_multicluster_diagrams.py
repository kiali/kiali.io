#!/usr/bin/env python3
"""Generate OSSM multicluster tutorial architecture SVG + PNG diagrams.

Writes to static/images/ossm-multicluster/. Embedded by the guides under
content/en/docs/Tutorials/ossm-multicluster/.

Requires: rsvg-convert (librsvg)

  python3 scripts/generate_ossm_multicluster_diagrams.py
"""

from __future__ import annotations

import html
import os
import subprocess
from dataclasses import dataclass, field
from typing import Optional

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_REPO_ROOT = os.path.dirname(_SCRIPT_DIR)
OUT_DIR = os.path.join(_REPO_ROOT, "static", "images", "ossm-multicluster")

# Guide badge colors (reserved — flow strokes must not reuse these)
COLORS = {
    "G1": "#1f77b4",  # blue
    "G2": "#d62728",  # red
    "G3": "#2ca02c",  # green
    "G4": "#9467bd",  # purple
    "prior": "#9aa0a6",
    "cluster": "#e8eef5",
    "cluster_stroke": "#5a6a7a",
    "box": "#fafbfc",  # same as diagram bg / flow-label pills
    "box_stroke": "#334455",
    "box_prior": "#fafbfc",  # same fill; prior is conveyed by muted stroke/text
    "box_prior_stroke": "#a0a8b0",
    "text": "#1a1a1a",
    "text_muted": "#6b7280",
    "bg": "#fafbfc",
    # Flow strokes — global semantics (same meaning in every diagram); never G1–G4 hues
    "arrow_metrics": "#e67e22",  # orange: query metrics/backends (Kiali, Perses, Tempo)
    "arrow_metrics_collect": "#b35900",  # darker orange: scrape / ACM collect / forward into storage
    "arrow_mesh": "#0e7c8a",  # teal: East-West mesh only
    "arrow_trace": "#8c564b",  # brown: traces→Tempo only
    "arrow_api": "#a63d7a",  # magenta: Kiali auth (remote kubeconfig) only
    "arrow_mgmt": "#7a7b18",  # olive: ACM import / manage only
}


@dataclass
class Box:
    x: float
    y: float
    w: float
    h: float
    title: str
    lines: list[str] = field(default_factory=list)
    badge: str = ""  # e.g. "G1·P3"
    prior: bool = False
    guide: str = "G1"


@dataclass
class Cluster:
    x: float
    y: float
    w: float
    h: float
    name: str
    role: str


@dataclass
class Arrow:
    x1: float
    y1: float
    x2: float
    y2: float
    label: str
    color: str
    dashed: bool = False
    double_headed: bool = False
    # Optional absolute label position (defaults to midpoint, slightly above the line)
    label_x: Optional[float] = None
    label_y: Optional[float] = None
    # Optional override for the label pill width (defaults from label length)
    label_pill_w: Optional[float] = None
    # Pill fill (defaults to diagram bg; use cluster fill when the label sits inside a cluster)
    label_pill_fill: Optional[str] = None
    # Optional elbow corner (draws x1,y1 → via → x2,y2; arrowhead on last leg)
    via_x: Optional[float] = None
    via_y: Optional[float] = None


class SvgCanvas:
    def __init__(self, width: int, height: int, title: str):
        self.width = width
        self.height = height
        self.title = title
        self.parts: list[str] = []
        self._arrow_seq = 0

    def add(self, s: str) -> None:
        self.parts.append(s)

    def rect(
        self,
        x: float,
        y: float,
        w: float,
        h: float,
        fill: str,
        stroke: str,
        sw: float = 1.5,
        rx: float = 6,
        opacity: float = 1.0,
    ) -> None:
        self.add(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" '
            f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}" opacity="{opacity}"/>'
        )

    def text(
        self,
        x: float,
        y: float,
        content: str,
        size: float = 12,
        weight: str = "normal",
        fill: Optional[str] = None,
        anchor: str = "start",
        family: str = "DejaVu Sans, Liberation Sans, Arial, sans-serif",
    ) -> None:
        fill = fill or COLORS["text"]
        esc = html.escape(content)
        self.add(
            f'<text x="{x}" y="{y}" font-size="{size}" font-weight="{weight}" '
            f'fill="{fill}" text-anchor="{anchor}" font-family="{family}">{esc}</text>'
        )

    def badge_width(self, label: str) -> float:
        # Sized for 12px bold DejaVu Sans (calibrated via Pango); pad ~16px total
        # Old 11*len+14 made G2:P4.2-4.4 pills ~135px for ~64px of glyphs and starved titles.
        return max(52, 6.0 * len(label) + 16)

    def badge(
        self,
        x: float,
        y: float,
        label: str,
        guide: str,
        prior: bool = False,
        width: Optional[float] = None,
    ) -> None:
        color = COLORS["prior"] if prior else COLORS.get(guide, COLORS["G1"])
        tw = width if width is not None else self.badge_width(label)
        self.rect(x, y, tw, 20, color, color, sw=0, rx=3)
        self.text(x + tw / 2, y + 15, label, size=12, weight="bold", fill="#ffffff", anchor="middle")

    def wrap_text(self, content: str, max_w: float, size: float = 13, weight: str = "bold") -> list[str]:
        """Word-wrap by approximate DejaVu width so titles stay inside the box.

        Slightly overestimate char width so wrapping triggers before the glyph
        actually hits the right border (bold proportional fonts run wider than
        a naive average).
        """
        char_w = size * (0.58 if weight == "bold" else 0.52)
        if not content or len(content) * char_w <= max_w:
            return [content] if content else []
        words = content.split()
        lines: list[str] = []
        cur = ""
        for word in words:
            trial = f"{cur} {word}".strip()
            if len(trial) * char_w <= max_w:
                cur = trial
            else:
                if cur:
                    lines.append(cur)
                cur = word
        if cur:
            lines.append(cur)
        return lines or [content]

    def draw_box(self, b: Box) -> None:
        fill = COLORS["box_prior"] if b.prior else COLORS["box"]
        stroke = COLORS["box_prior_stroke"] if b.prior else COLORS["box_stroke"]
        self.rect(b.x, b.y, b.w, b.h, fill, stroke, sw=1.2, rx=4)
        title_fill = COLORS["text_muted"] if b.prior else COLORS["text"]
        # Badge left of title so phase labels never sit on top of the title text
        title_x = b.x + 8
        if b.badge:
            bw = self.badge_width(b.badge)
            self.badge(b.x + 6, b.y + 4, b.badge, b.guide, b.prior)
            title_x = b.x + 6 + bw + 10
        title_max_w = b.x + b.w - 8 - title_x
        title_lines = self.wrap_text(b.title, title_max_w, size=13, weight="bold")
        for i, tline in enumerate(title_lines):
            self.text(title_x, b.y + 18 + i * 15, tline, size=13, weight="bold", fill=title_fill)
        body_y0 = b.y + 36 + max(0, len(title_lines) - 1) * 15
        for i, line in enumerate(b.lines):
            self.text(
                b.x + 8,
                body_y0 + i * 15,
                line,
                size=12,
                fill=COLORS["text_muted"] if b.prior else COLORS["text"],
            )

    def draw_cluster(self, c: Cluster) -> None:
        self.rect(c.x, c.y, c.w, c.h, COLORS["cluster"], COLORS["cluster_stroke"], sw=2, rx=8)
        self.text(c.x + 12, c.y + 24, c.name, size=17, weight="bold")
        self.text(c.x + 12, c.y + 42, c.role, size=13, fill=COLORS["text_muted"])

    def draw_arrow(self, a: Arrow) -> None:
        dash = ' stroke-dasharray="6 4"' if a.dashed else ""
        mid_x = (a.x1 + a.x2) / 2
        mid_y = (a.y1 + a.y2) / 2
        # Stable unique marker id per arrow (do not use id(a) — GC can reuse addresses)
        self._arrow_seq += 1
        mid_end = f"arrow-end-{self._arrow_seq}"
        self.add(
            f'<defs><marker id="{mid_end}" markerWidth="8" markerHeight="8" '
            f'refX="7" refY="3" orient="auto"><path d="M0,0 L8,3 L0,6 Z" fill="{a.color}"/></marker></defs>'
        )
        has_via = a.via_x is not None and a.via_y is not None
        if a.double_headed and not has_via:
            mid_start = f"arrow-start-{self._arrow_seq}"
            # Flipped path so the start head points outward (toward x1,y1)
            self.add(
                f'<defs><marker id="{mid_start}" markerWidth="8" markerHeight="8" '
                f'refX="1" refY="3" orient="auto">'
                f'<path d="M8,0 L0,3 L8,6 Z" fill="{a.color}"/></marker></defs>'
            )
            self.add(
                f'<line x1="{a.x1}" y1="{a.y1}" x2="{a.x2}" y2="{a.y2}" '
                f'stroke="{a.color}" stroke-width="2"{dash} '
                f'marker-start="url(#{mid_start})" marker-end="url(#{mid_end})"/>'
            )
        elif has_via:
            # Elbow: first leg plain, second leg gets the arrowhead
            self.add(
                f'<line x1="{a.x1}" y1="{a.y1}" x2="{a.via_x}" y2="{a.via_y}" '
                f'stroke="{a.color}" stroke-width="2"{dash}/>'
            )
            self.add(
                f'<line x1="{a.via_x}" y1="{a.via_y}" x2="{a.x2}" y2="{a.y2}" '
                f'stroke="{a.color}" stroke-width="2"{dash} marker-end="url(#{mid_end})"/>'
            )
            mid_x = a.via_x
            mid_y = (a.y1 + a.via_y) / 2
        else:
            self.add(
                f'<line x1="{a.x1}" y1="{a.y1}" x2="{a.x2}" y2="{a.y2}" '
                f'stroke="{a.color}" stroke-width="2"{dash} marker-end="url(#{mid_end})"/>'
            )
        if a.label:
            lx = a.label_x if a.label_x is not None else mid_x
            ly = a.label_y if a.label_y is not None else mid_y - 12
            # Opaque pill matching diagram bg; "\n" stacks lines (narrow gutters only)
            lines = a.label.split("\n")
            longest = max(lines, key=len)
            pill_w = a.label_pill_w if a.label_pill_w is not None else max(56, 7.6 * len(longest) + 20)
            # Single-line pills stay 20px (pre-wrap size); each extra line adds 14px
            pill_h = 20 + 14 * (len(lines) - 1)
            bg = a.label_pill_fill if a.label_pill_fill is not None else COLORS["bg"]
            pill_top = ly - 14
            self.rect(lx - pill_w / 2, pill_top, pill_w, pill_h, bg, bg, sw=0, rx=3, opacity=1.0)
            for i, line in enumerate(lines):
                self.text(lx, ly + i * 14, line, size=13, weight="bold", fill=a.color, anchor="middle")

    def legend(
        self,
        x: float,
        y: float,
        items: list[tuple[str, str, str]],
        arrows: list[tuple[str, str]],
        *,
        title: Optional[str] = "Legend",
        flows_title: Optional[str] = "Flows",
        badge_w: Optional[float] = None,
    ) -> None:
        cy = y
        if items:
            # Fixed pill width keeps multi-column legends aligned (overrides per-label sizing)
            tw = badge_w if badge_w is not None else max(
                (self.badge_width(label) for label, _, _ in items), default=52.0
            )
            if title:
                self.text(x, cy, title, size=14, weight="bold")
                cy += 22
            for label, guide, desc in items:
                self.badge(
                    x, cy - 14, label, guide, prior=(label in ("prior", "optional")), width=tw
                )
                self.text(x + tw + 10, cy, desc, size=12)
                cy += 24
            if arrows:
                cy += 8
        if arrows:
            if flows_title:
                self.text(x, cy, flows_title, size=14, weight="bold")
                cy += 20
            for color, desc in arrows:
                self.add(
                    f'<line x1="{x}" y1="{cy - 4}" x2="{x + 28}" y2="{cy - 4}" '
                    f'stroke="{color}" stroke-width="2"/>'
                )
                self.text(x + 34, cy, desc, size=12)
                cy += 20

    def render(self) -> str:
        body = "\n".join(self.parts)
        return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{self.width}" height="{self.height}"
     viewBox="0 0 {self.width} {self.height}">
  <rect width="100%" height="100%" fill="{COLORS["bg"]}"/>
  <text x="24" y="30" font-size="20" font-weight="bold"
        font-family="DejaVu Sans, Liberation Sans, Arial, sans-serif"
        fill="{COLORS["text"]}">{html.escape(self.title)}</text>
{body}
</svg>
'''


def write_svg_png(name: str, svg: str) -> None:
    svg_path = os.path.join(OUT_DIR, f"{name}.svg")
    png_path = os.path.join(OUT_DIR, f"{name}.png")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg)
    # Higher pixel width keeps inline PNGs sharper when Docsy scales them down
    subprocess.run(
        ["rsvg-convert", "-w", "2400", "-o", png_path, svg_path],
        check=True,
    )
    print(f"Wrote {svg_path} and {png_path}")


# ---------------------------------------------------------------------------
# Diagram 01 — Hub/Spoke (Guide 1)
# ---------------------------------------------------------------------------

def diagram_01() -> str:
    c = SvgCanvas(1220, 880, "Guide 1 — MultiCluster on OpenShift (hub + spoke)")
    hub = Cluster(40, 50, 400, 520, "ossm-kiali-hub", "ACM hub — fleet + Thanos metrics")
    # Spoke starts after a ~140px gutter so flow labels fit without covering cluster borders
    spoke = Cluster(580, 50, 600, 540, "ossm-kiali-spoke", "Istio mesh + Kiali")
    c.draw_cluster(hub)
    c.draw_cluster(spoke)

    # Hub boxes — badges use G#:P… (§ range); "-" is the range delimiter.
    # Body "(n.n)" only when the pill spans multiple subsections.
    for b in [
        Box(55, 100, 370, 70, "ACM Operator + MultiClusterHub", ["OLM Subscription (1.1)", "MCH Running (1.2)"], "G1:P1.1-1.2", guide="G1"),
        # Certs are an MCO side effect in 1.4; extract/apply for Kiali is G1:P4.1-4.2 on the spoke
        Box(55, 185, 370, 90, "ACM Observability (MCO)", ["MinIO object store (1.4)", "Thanos + Observatorium API + certs (1.4)", "MCOA ScrapeConfig + PrometheusRule (1.5)"], "G1:P1.4-1.5", guide="G1"),
        Box(55, 290, 370, 95, "ManagedCluster: spoke", ["ManagedCluster + namespace (2.1)", "auto-import-secret (2.2)", "KlusterletAddonConfig (2.3)"], "G1:P2.1-2.3", guide="G1"),
    ]:
        c.draw_box(b)

    # Spoke — compact two columns (boxes sized to content, not stretched)
    for b in [
        Box(600, 100, 250, 55, "Klusterlet agent", ["ACM add-ons"], "G1:P2.4", guide="G1"),
        # Taller so wrapped title ("User Workload" / "Monitoring") + body fit
        Box(600, 170, 250, 70, "User Workload Monitoring", ["UWM Prometheus"], "G1:P3.1", guide="G1"),
        # Pill starts at 3.2 (Sail operator); 3.3 namespaces are implied between operator and cacerts
        Box(600, 255, 250, 125, "OSSM 3 / Sail", ["Sail operator (3.2)", "cacerts (3.4)", "IstioCNI (3.5), Istio (3.6)", "ZTunnel (3.7)", "istiod + ztunnel monitors (3.8)"], "G1:P3.2-3.8", guide="G1"),
        # Right column wide enough for "bookinfo (sidecar demo)" on one line
        Box(870, 100, 290, 100, "Kiali", ["Operator (4.3)", "Kiali server (4.4)", "OSSMConsole plugin (4.5)"], "G1:P4.3-4.5", guide="G1"),
        Box(870, 220, 290, 85, "Metrics certs", ["extract hub Observatorium certs (4.1)", "acm-observability-certs + kiali-cabundle (4.2)"], "G1:P4.1-4.2", guide="G1"),
        Box(600, 395, 250, 100, "ambient-demo", ["helloworld v1/v2, traffic-gen", "waypoint Gateway", "PodMonitor"], "G1:P5.1", guide="G1"),
        Box(870, 395, 290, 100, "bookinfo (sidecar demo)", ["full Bookinfo + gateway (5.2)", "traffic-gen (5.2)", "PodMonitor (5.3)"], "G1:P5.2-5.3", guide="G1"),
        Box(600, 515, 560, 55, "Metrics scrape path", ["UWM scrapes Istio to ACM collector to hub Thanos"], "G1:P3.8", guide="G1"),
    ]:
        c.draw_box(b)

    # Gutter center x=510 (hub ends 440, spoke starts 580).
    # Labels offset ~30px from their own stroke; bands stay separated vertically.
    c.draw_arrow(
        Arrow(
            870,
            150,
            425,
            200,
            "query metrics",
            COLORS["arrow_metrics"],
            label_x=510,
            label_y=175,
        )
    )
    c.draw_arrow(
        Arrow(
            425,  # right edge of ManagedCluster: spoke
            337,
            600,
            130,
            "import / manage",
            COLORS["arrow_mgmt"],
            label_x=510,
            label_y=250,
            label_pill_w=100,  # fit hub↔spoke gutter
        )
    )
    c.draw_arrow(
        Arrow(
            600,
            542,
            425,
            230,
            "forward metrics",
            COLORS["arrow_metrics_collect"],
            label_x=510,
            label_y=400,
        )
    )

    # Legend below clusters — fixed pill width so columns look organized
    # Spoke ends ~590; leave a clear gap before Legend / Flows
    _g1_legend_badge_w = 135.0
    c.legend(
        40,
        630,
        [
            ("G1:P1.1-1.2", "G1", "ACM Operator + MultiClusterHub"),
            ("G1:P1.4-1.5", "G1", "ACM Observability + MCOA federation"),
            ("G1:P2.1-2.3", "G1", "ManagedCluster import"),
            ("G1:P2.4", "G1", "Spoke joined / Klusterlet"),
        ],
        [],
        badge_w=_g1_legend_badge_w,
    )
    c.legend(
        420,
        652,  # align with first item under the single "Legend" title
        [
            ("G1:P3.1", "G1", "User Workload Monitoring"),
            ("G1:P3.2-3.8", "G1", "Istio control plane (mesh stack)"),
            ("G1:P4.1-4.2", "G1", "Spoke metrics certs"),
            ("G1:P4.3-4.5", "G1", "Kiali + OSSMConsole"),
            ("G1:P5.1", "G1", "Ambient demo (+ waypoint)"),
            ("G1:P5.2-5.3", "G1", "Bookinfo sidecar demo"),
        ],
        [],
        title=None,
        badge_w=_g1_legend_badge_w,
    )
    c.legend(
        840,
        630,
        [],
        [
            (COLORS["arrow_metrics"], "Metrics query (Kiali to hub Thanos)"),
            (COLORS["arrow_metrics_collect"], "Metrics forward (spoke to hub Thanos)"),
            (COLORS["arrow_mgmt"], "ACM import / manage"),
        ],
    )
    c.text(
        40,
        850,
        "Badges are guide section numbers (G1:P3.2-3.8 = Guide 1, §§3.2–3.8). Hub has no Istio; mesh runs only on the spoke.",
        size=11,
        fill=COLORS["text_muted"],
    )
    return c.render()


# ---------------------------------------------------------------------------
# Diagram 02 — Multi-Primary (Guide 2)
# ---------------------------------------------------------------------------

def diagram_02() -> str:
    c = SvgCanvas(1340, 960, "Guide 2 — Multi-Primary Mesh (two Istio primaries)")
    # Spoke nudged left so hub↔spoke still fits "metrics"; wider spoke↔spoke-two gutter for wrapped labels
    hub = Cluster(20, 50, 280, 670, "ossm-kiali-hub", "ACM hub (unchanged)")
    spoke = Cluster(365, 50, 530, 670, "ossm-kiali-spoke", "Istio primary 1 + Kiali")
    spoke2 = Cluster(985, 50, 280, 670, "ossm-kiali-spoke-two", "Istio primary 2 (new)")
    c.draw_cluster(hub)
    c.draw_cluster(spoke)
    c.draw_cluster(spoke2)

    # Hub — prior + new ManagedCluster (Phase 2 has no ### subsections)
    # Body "(n.n)" only when the pill spans multiple subsections.
    for b in [
        Box(35, 100, 250, 70, "ACM + Thanos", ["MCO / Observatorium", "(from Guide 1)"], "prior", prior=True, guide="G1"),
        Box(35, 185, 250, 70, "ManagedCluster: spoke", ["(from Guide 1)"], "prior", prior=True, guide="G1"),
        Box(35, 270, 250, 85, "ManagedCluster: spoke-two", ["KlusterletAddonConfig", "auto-import secret"], "G2:P2", guide="G2"),
    ]:
        c.draw_box(b)

    # Spoke — prior + Guide 2 section badges
    for b in [
        Box(385, 100, 250, 75, "OSSM / ZTunnel / apps", ["ambient-demo, bookinfo", "(from Guide 1)"], "prior", prior=True, guide="G1"),
        Box(650, 100, 230, 75, "Kiali server", ["Observatorium metrics", "(from Guide 1)"], "prior", prior=True, guide="G1"),
        Box(385, 190, 250, 100, "Multi-primary config", ["Istio identity (4.2)", "ZTunnel identity (4.3)", "Kiali cluster_name (4.4)"], "G2:P4.2-4.4", guide="G2"),
        Box(650, 190, 230, 100, "East-West gateways", ["HBONE (5.1)", "sidecar (5.2)", "meshNetworks (5.3)"], "G2:P5.1-5.3", guide="G2"),
        Box(385, 305, 250, 85, "Istio remote secret", ["istio-reader SA (6.1)", "secret from spoke-two (6.2)"], "G2:P6.1-6.2", guide="G2"),
        Box(650, 305, 230, 85, "Multi-cluster secret", ["kubeconfig for spoke-two", "watched by operator"], "G2:P7.3", guide="G2"),
        Box(385, 405, 495, 55, "Federated services", ["helloworld + ratings with istio.io/global=true"], "G2:P8.1", guide="G2"),
    ]:
        c.draw_box(b)

    # Spoke-two — heights fit wrapped titles + body lines
    for b in [
        Box(1005, 100, 240, 55, "Intermediate CA / cacerts", [], "G2:P1", guide="G2"),
        Box(1005, 170, 240, 50, "Klusterlet (ACM join)", [], "G2:P2", guide="G2"),
        # The stack begins with certificate setup (3.4); UWM, the operator, and namespace setup are not depicted.
        Box(1005, 235, 240, 100, "OSSM 3 stack", ["cacerts (3.4)", "IstioCNI (3.5), Istio (3.6)", "ZTunnel (3.7)", "monitors (3.8)"], "G2:P3.4-3.8", guide="G2"),
        Box(1005, 350, 240, 85, "East-West gateways", ["HBONE (5.1), sidecar (5.2)", "meshNetworks (5.3)"], "G2:P5.1-5.3", guide="G2"),
        Box(1005, 450, 240, 55, "Istio remote secret", ["from spoke"], "G2:P6.3", guide="G2"),
        # Tall enough for wrapped title under G2:P7.1-7.2 badge + 2 body lines
        Box(1005, 520, 240, 100, "Kiali remote resources", ["Operator (7.1)", "remote Kiali resources + SA token (7.2)"], "G2:P7.1-7.2", guide="G2"),
        Box(1005, 635, 240, 70, "Demo apps", ["helloworld + waypoint (8.1)", "ratings-v2 (8.2)"], "G2:P8.1-8.2", guide="G2"),
    ]:
        c.draw_box(b)

    # Solid flows; labels wrap to fit the spoke↔spoke-two gutter
    # EW: spoke East-West right (880) ↔ spoke-two East-West left (1005)
    c.draw_arrow(
        Arrow(
            880,
            240,
            1005,
            390,
            "EW mesh\ntraffic",
            COLORS["arrow_mesh"],
            double_headed=True,
            label_x=942,
            label_y=300,
            label_pill_w=58,
        )
    )
    # Kiali auth: multi-cluster secret right (880) → Kiali remote left (1005)
    c.draw_arrow(
        Arrow(
            880,
            347,
            1005,
            557,
            "Kiali\nauth",
            COLORS["arrow_api"],
            label_x=942,
            label_y=458,
            label_pill_w=52,
        )
    )
    # Metrics forward: OSSM/ZTunnel left (385) → ACM + Thanos (horizontal)
    c.draw_arrow(
        Arrow(
            385,
            137,
            285,
            137,
            "metrics",
            COLORS["arrow_metrics_collect"],
            # Hub ends 300, spoke starts 365 — 56px pill centered in that gutter
            label_x=332,
            label_y=128,
            label_pill_w=56,
        )
    )
    # Import: ManagedCluster spoke-two right edge (285) → Klusterlet left (1005)
    c.draw_arrow(
        Arrow(
            285,
            312,
            1005,
            190,
            "import\nspoke-two",
            COLORS["arrow_mgmt"],
            # Above the import stroke in the spoke↔spoke-two gutter
            label_x=940,
            label_y=175,
            label_pill_w=72,
        )
    )

    # Legend once; Flows to the right — fixed pill width across columns
    _g2_legend_badge_w = 135.0
    c.legend(
        40,
        740,
        [
            ("prior", "G1", "From Guide 1"),
            ("G2:P1", "G2", "Spoke-two CA"),
            ("G2:P2", "G2", "ACM import spoke-two"),
            ("G2:P3.4-3.8", "G2", "Istio CP on spoke-two"),
            ("G2:P4.2-4.4", "G2", "Update spoke Istio identity"),
            ("G2:P5.1-5.3", "G2", "East-West gateways"),
        ],
        [],
        badge_w=_g2_legend_badge_w,
    )
    c.legend(
        420,
        762,
        [
            ("G2:P6.1-6.2", "G2", "Remote secret on spoke"),
            ("G2:P6.3", "G2", "Remote secret on spoke-two"),
            ("G2:P7.1-7.2", "G2", "Kiali remote CR on spoke-two"),
            ("G2:P7.3", "G2", "kiali-multi-cluster-secret"),
            ("G2:P8.1-8.2", "G2", "Cross-cluster demo apps"),
        ],
        [],
        title=None,
        badge_w=_g2_legend_badge_w,
    )
    c.legend(
        820,
        740,
        [],
        [
            (COLORS["arrow_mesh"], "East-West mesh traffic"),
            (COLORS["arrow_api"], "Kiali auth (remote kubeconfig)"),
            (COLORS["arrow_metrics_collect"], "Metrics forward to hub Thanos"),
            (COLORS["arrow_mgmt"], "ACM import / manage"),
        ],
    )
    c.text(
        20,
        920,
        "Badges are guide section numbers (G2:P5.1-5.3 = Guide 2, §§5.1–5.3). Hub stays ACM-only; both spokes are Istio primaries.",
        size=11,
        fill=COLORS["text_muted"],
    )
    return c.render()


# ---------------------------------------------------------------------------
# Diagram 03 — Dashboards & Tracing (Guide 3)
# ---------------------------------------------------------------------------

def diagram_03() -> str:
    c = SvgCanvas(1600, 900, "Guide 3 — Dashboards and Tracing (Perses + Tempo)")
    # ~60px gutters for flow labels; legend below clusters (Guide 1/2 layout)
    hub = Cluster(20, 50, 280, 620, "ossm-kiali-hub", "ACM hub + Thanos")
    spoke = Cluster(360, 50, 560, 620, "ossm-kiali-spoke", "Kiali + Perses + Tempo")
    spoke2 = Cluster(980, 50, 380, 620, "ossm-kiali-spoke-two", "OTEL forwarder")
    c.draw_cluster(hub)
    c.draw_cluster(spoke)
    c.draw_cluster(spoke2)

    # Hub — prior from Guides 1–2
    for b in [
        Box(35, 100, 250, 90, "Hub Thanos / Observatorium", ["(from Guide 1)", "Perses + Kiali query here"], "prior", prior=True, guide="G1"),
        Box(35, 210, 250, 70, "ManagedClusters", ["spoke + spoke-two", "(from Guides 1–2)"], "prior", prior=True, guide="G1"),
    ]:
        c.draw_box(b)

    # Spoke — badges use G#:P…; body "(n.n)" only for multi-subsection pills
    for b in [
        Box(380, 100, 260, 70, "Mesh + Kiali", ["multi-primary mesh", "(from Guides 1–2)"], "prior", prior=True, guide="G1"),
        Box(660, 100, 240, 70, "East-West / demos", ["(from Guide 2)"], "prior", prior=True, guide="G2"),
        Box(380, 190, 520, 55, "Cluster Observability Operator", ["COO"], "G3:P1.1", guide="G3"),
        Box(380, 260, 260, 100, "Perses", ["Monitoring UIPlugin (1.2)", "PersesDatasource (1.3)", "3 Istio dashboards (1.4)"], "G3:P1.2-1.4", guide="G3"),
        Box(660, 260, 240, 100, "Perses mTLS + Kiali config", ["perses-acm-server-ca (1.3)", "perses-acm-client-certs (1.3)", "Kiali config (1.5)"], "G3:P1.3/1.5", guide="G3"),
        Box(380, 380, 260, 110, "TempoStack", ["Tempo + OpenTelemetry Operators (2.1)", "MinIO in tempo ns (2.2)", "gateway ClusterRoles (2.3)"], "G3:P2.1-2.3", guide="G3"),
        Box(660, 380, 240, 110, "OTEL on spoke", ["local collector (2.4)", "remote receiver + Route (2.5)", "mTLS server/client certs (2.5)"], "G3:P2.4-2.5", guide="G3"),
        Box(380, 510, 520, 70, "Istio tracing config", ["Istio extensionProviders + Telemetry CR (2.7)", "DistributedTracing UIPlugin (2.8)"], "G3:P2.7-2.8", guide="G3"),
        Box(380, 600, 520, 55, "Kiali Tempo config", ["external_services.tracing"], "G3:P2.9", guide="G3"),
    ]:
        c.draw_box(b)

    # Spoke-two
    for b in [
        Box(1000, 100, 340, 70, "Mesh + demos", ["(from Guide 2)"], "prior", prior=True, guide="G2"),
        Box(1000, 190, 340, 95, "OTEL forwarder", ["OpenTelemetry Operator", "otel-collector to spoke Route", "k8s.cluster.name=spoke-two"], "G3:P2.6", guide="G3"),
        Box(1000, 305, 340, 70, "Istio Telemetry CR", ["extensionProviders", "sampling 100%"], "G3:P2.7", guide="G3"),
    ]:
        c.draw_box(b)

    # Solid flows; endpoints on box edges; labels in gutters (may sit on the stroke)
    # Metrics: Perses left (380) → Hub Thanos right (285)
    c.draw_arrow(
        Arrow(
            380,
            310,
            285,
            145,
            "metrics",
            COLORS["arrow_metrics"],
            # Hub ends 300, spoke starts 360
            label_x=330,
            label_y=220,
            label_pill_w=56,
        )
    )
    # Traces: OTEL forwarder (spoke-two) → OTEL on spoke (top-right).
    # Short gutter hop only — local OTEL→Tempo is implied by adjacency + Flows legend.
    c.draw_arrow(
        Arrow(
            1000,
            250,
            900,
            400,
            "traces",
            COLORS["arrow_trace"],
            label_x=950,
            label_y=310,
            label_pill_w=52,
        )
    )
    # Kiali queries Tempo gateway (internal_url) — mid-right of Kiali top → TempoStack bottom.
    # Crosses the empty right side of Istio tracing; label sits there clear of text/border.
    c.draw_arrow(
        Arrow(
            750,
            600,
            590,
            490,  # TempoStack bottom edge (y=380, h=110)
            "query Tempo",
            COLORS["arrow_metrics"],
            label_x=735,
            label_y=545,
            label_pill_w=90,
        )
    )

    # Legend once; Flows to the right — fixed pill width across columns
    _g3_legend_badge_w = 135.0
    c.legend(
        40,
        695,
        [
            ("prior", "G1", "From Guides 1–2"),
            ("G3:P1.1", "G3", "Cluster Observability Operator"),
            ("G3:P1.2-1.4", "G3", "Perses + dashboards"),
            ("G3:P1.3/1.5", "G3", "Perses mTLS + Kiali config"),
            ("G3:P2.1-2.3", "G3", "TempoStack + operators + RBAC"),
        ],
        [],
        badge_w=_g3_legend_badge_w,
    )
    c.legend(
        420,
        717,  # align with first item under the single "Legend" title
        [
            ("G3:P2.4-2.5", "G3", "OTEL on spoke"),
            ("G3:P2.6", "G3", "OTEL forwarder (spoke-two)"),
            ("G3:P2.7-2.8", "G3", "Istio tracing / Telemetry"),
            ("G3:P2.9", "G3", "Kiali Tempo config"),
        ],
        [],
        title=None,
        badge_w=_g3_legend_badge_w,
    )
    c.legend(
        820,
        695,
        [],
        [
            (COLORS["arrow_metrics"], "Metrics / Tempo query to backends"),
            (COLORS["arrow_trace"], "Traces to Tempo"),
        ],
    )
    c.text(
        20,
        870,
        "Badges are guide section numbers (G3:P2.4-2.5 = Guide 3, §§2.4–2.5). Phase 1 adds Perses; Phase 2 adds multi-cluster Tempo via OTEL.",
        size=11,
        fill=COLORS["text_muted"],
    )
    return c.render()


# ---------------------------------------------------------------------------
# Diagram 04 — Health Status Alerts (Guide 4)
# ---------------------------------------------------------------------------

def diagram_04() -> str:
    c = SvgCanvas(1400, 740, "Guide 4 — Health Status Alerts + Network Health")
    # ~60px hub↔spoke gutter for the ACM collect label
    # Matching cluster heights; spoke content sets the height (~495 + pad)
    hub = Cluster(40, 50, 340, 465, "ossm-kiali-hub (optional)", "Phase 6 — ACM Observability")
    spoke = Cluster(440, 50, 800, 465, "Cluster running Kiali", "e.g. ossm-kiali-spoke (single- or multi-cluster)")
    c.draw_cluster(hub)
    c.draw_cluster(spoke)

    # Hub — Phase 6 (+ optional routing after phases)
    for b in [
        Box(55, 100, 310, 90, "MCOA health federation", ["ScrapeConfig/kiali-health-federation", "PrometheusRule/kiali-health-aggregation"], "G4:P6.1", guide="G4"),
        Box(55, 210, 310, 95, "Thanos Ruler custom rules", ["KialiHubHealthFailure", "KialiHubHealthDegraded", "Namespace Failure"], "G4:P6.3", guide="G4"),
        Box(55, 325, 310, 70, "ACM Alertmanager routing", ["Slack / email / webhook"], "optional", prior=True, guide="G4"),
    ]:
        c.draw_box(b)

    # Spoke — body "(n.n)" only when the pill spans multiple subsections
    for b in [
        Box(460, 100, 360, 90, "User Workload Monitoring", ["enableUserWorkload"], "G4:P1.2", guide="G4"),
        Box(860, 100, 360, 90, "Kiali CR metrics export", ["server.observability.metrics", "health_status.enabled", "gauge: kiali_health_status"], "G4:P2.1", guide="G4"),
        Box(460, 240, 360, 90, "ServiceMonitor: kiali", ["HTTPS :9090 tcp-metrics", "CA: kiali-cabundle-openshift"], "G4:P3.2", guide="G4"),
        Box(860, 240, 360, 90, "PrometheusRule: alerts", ["kiali:health_status:max", "KialiHealthFailure / Degraded", "to Observe > Alerting"], "G4:P4.1", guide="G4"),
        Box(460, 350, 760, 70, "Phase 5 demo (temporary)", ["Tighten health_config (5.2)", "VirtualService abort (5.3) — forces Failure"], "G4:P5.2-5.3", guide="G4"),
        Box(460, 440, 360, 55, "Route alerts", ["Alertmanager to Slack / email / webhook"], "optional", prior=True, guide="G4"),
        Box(860, 440, 360, 55, "NetObserv Network Health", ["Operator + FlowCollector (7.1-7.2)", "annotated rules to Observe > Network Health"], "G4:P7.1-7.3", guide="G4"),
    ]:
        c.draw_box(b)

    # Solid flows; endpoints on box edges; labels in the mid-row gap
    # scrape: ServiceMonitor tells UWM what to pull — stroke ends at Kiali (the scrape target).
    # Do not draw Kiali→PrometheusRule: rules evaluate series already in UWM, they are not an export sink.
    c.draw_arrow(
        Arrow(
            820,
            285,
            860,
            190,
            "scrape",
            COLORS["arrow_metrics_collect"],
            # In the gap above PrometheusRule (y=240); keep pill clear of that box
            label_x=838,
            label_y=228,
            label_pill_w=52,
            label_pill_fill=COLORS["cluster"],
        )
    )
    # MCOA federation: spoke UWM left → hub MCOA health resources right (gutter; hub ends 380, spoke 440)
    c.draw_arrow(
        Arrow(
            460,
            145,
            365,
            145,
            "ACM\ncollect",
            COLORS["arrow_metrics_collect"],
            label_x=405,
            label_y=112,
            label_pill_w=48,
        )
    )

    # Legend left (two columns); Flows to the right — same layout as Guides 1–3
    # Spoke cluster ends ~515; leave a clear gap before Legend / Flows
    c.legend(
        40,
        545,
        [
            ("G4:P1.2", "G4", "Enable UWM"),
            ("G4:P2.1", "G4", "Export health gauge"),
            ("G4:P3.2", "G4", "ServiceMonitor scrape"),
            ("G4:P4.1", "G4", "Recording rules + alerts"),
        ],
        [],
    )
    c.legend(
        400,
        567,
        [
            ("G4:P5.2-5.3", "G4", "Hands-on Failure demo"),
            ("G4:P6.1", "G4", "Hub MCOA health federation"),
            ("G4:P6.3", "G4", "Hub Thanos Ruler alerts"),
            ("G4:P7.1-7.3", "G4", "NetObserv Network Health"),
            ("optional", "G4", "Alertmanager routing"),
        ],
        [],
        title=None,
    )
    c.legend(
        780,
        545,
        [],
        [
            (COLORS["arrow_metrics_collect"], "Metrics scrape / ACM collect to hub"),
        ],
    )
    c.text(
        40,
        700,
        "Badges are guide section numbers (G4:P5.2-5.3 = Guide 4, §§5.2–5.3). Phases 1–5 run on the Kiali cluster; Phase 6 is optional ACM hub; Phase 7 is optional NetObserv.",
        size=11,
        fill=COLORS["text_muted"],
    )
    return c.render()


# ---------------------------------------------------------------------------
# Diagram 00 — Finished overview (index)
# ---------------------------------------------------------------------------

def diagram_00() -> str:
    c = SvgCanvas(1600, 1020, "Finished environment — MultiCluster on OpenShift + Kiali")
    hub = Cluster(20, 50, 360, 640, "ossm-kiali-hub", "ACM hub — no Istio")
    spoke = Cluster(400, 50, 560, 640, "ossm-kiali-spoke", "Istio primary 1 + Kiali home")
    spoke2 = Cluster(980, 50, 400, 640, "ossm-kiali-spoke-two", "Istio primary 2")
    c.draw_cluster(hub)
    c.draw_cluster(spoke)
    c.draw_cluster(spoke2)

    # Hub
    for b in [
        Box(35, 100, 330, 70, "ACM MCH + Observability", ["Thanos / Observatorium / MinIO"], "G1:P1", guide="G1"),
        Box(35, 185, 330, 55, "MCOA ScrapeConfig", [], "G1:P1", guide="G1"),
        # Full-width stacked so badge does not cover the ManagedCluster title
        Box(35, 255, 330, 40, "ManagedCluster: spoke", [], "G1:P2", guide="G1"),
        Box(35, 305, 330, 40, "ManagedCluster: spoke-two", [], "G2:P2", guide="G2"),
        Box(35, 360, 330, 70, "Thanos Ruler + MCOA health federation", ["kiali_health_status", "KialiHub* health alerts"], "G4:P6", guide="G4"),
    ]:
        c.draw_box(b)

    # Spoke — one badge per phase-owned piece (no mixed P# content in a single box)
    for b in [
        Box(420, 100, 250, 95, "OSSM 3 ambient", ["Istio, ZTunnel, CNI", "cacerts, monitors"], "G1:P3", guide="G1"),
        # Tall enough for wrapped title + 3 body lines
        Box(690, 100, 250, 95, "Multi-primary identity", ["clusterName, network", "AMBIENT_ENABLE_MULTI_NETWORK", "Kiali cluster_name"], "G2:P4", guide="G2"),
        Box(420, 210, 250, 75, "Kiali server", ["Observatorium mTLS", "OSSMConsole"], "G1:P4", guide="G1"),
        Box(690, 210, 250, 75, "East-West gateways", ["HBONE :15008, sidecar :15443", "meshNetworks"], "G2:P5", guide="G2"),
        Box(420, 300, 250, 55, "Multi-cluster secret", ["kiali-multi-cluster-secret"], "G2:P7", guide="G2"),
        Box(690, 300, 250, 55, "Istio remote secrets", ["endpoint discovery"], "G2:P6", guide="G2"),
        Box(420, 375, 520, 55, "Perses + Istio dashboards", ["COO · queries hub Thanos"], "G3:P1", guide="G3"),
        Box(420, 450, 520, 55, "TempoStack + OTEL", ["local + remote receiver / mTLS Route"], "G3:P2", guide="G3"),
        Box(420, 525, 250, 55, "ServiceMonitor: kiali", [], "G4:P3", guide="G4"),
        Box(690, 525, 250, 55, "PrometheusRule: alerts", [], "G4:P4", guide="G4"),
        Box(420, 600, 250, 70, "ambient-demo", ["helloworld + waypoint", "(base mesh apps)"], "G1:P5", guide="G1"),
        Box(690, 600, 250, 70, "bookinfo (cross-cluster)", ["ratings-v2 on spoke-two", "istio.io/global services"], "G2:P8", guide="G2"),
    ]:
        c.draw_box(b)

    # Spoke-two
    for b in [
        Box(1000, 100, 360, 50, "Intermediate CA / cacerts", [], "G2:P1", guide="G2"),
        Box(1000, 165, 360, 70, "OSSM 3 stack", ["IstioCNI, Istio, ZTunnel", "cluster/network identity"], "G2:P3", guide="G2"),
        Box(1000, 250, 360, 50, "East-West gateways", ["meshNetworks"], "G2:P5", guide="G2"),
        Box(1000, 315, 360, 50, "Istio remote secret", ["from spoke"], "G2:P6", guide="G2"),
        Box(1000, 380, 360, 50, "Kiali remote CR + SA", [], "G2:P7", guide="G2"),
        Box(1000, 445, 360, 50, "OTEL forwarder", ["to spoke Tempo"], "G3:P2", guide="G3"),
        Box(1000, 510, 360, 70, "Demo apps", ["helloworld + ratings-v2", "istio.io/global services"], "G2:P8", guide="G2"),
    ]:
        c.draw_box(b)

    # No flow arrows — overview is a component map; guide diagrams show connectivity.

    c.legend(
        40,
        710,
        [
            ("G1:Pn", "G1", "Guide 1: Hub/spoke foundation"),
            ("G2:Pn", "G2", "Guide 2: Multi-primary mesh"),
            ("G3:Pn", "G3", "Guide 3: Perses + Tempo"),
            ("G4:Pn", "G4", "Guide 4: Health status alerts"),
        ],
        [],
    )
    c.text(
        420,
        730,
        "Badges show which guide and phase install each piece (e.g. G2:P5 = Guide 2, Phase 5).",
        size=12,
        fill=COLORS["text"],
    )
    c.text(
        420,
        755,
        "Read Guides 1 to 2 to 3 in order. Guide 4 (health alerts) can also be followed standalone.",
        size=11,
        fill=COLORS["text_muted"],
    )
    c.text(
        420,
        780,
        "Each guide page has a progressive diagram of the environment as it exists when that guide finishes.",
        size=11,
        fill=COLORS["text_muted"],
    )
    return c.render()


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    write_svg_png("01-hub-spoke", diagram_01())
    write_svg_png("02-multi-primary", diagram_02())
    write_svg_png("03-dashboards-tracing", diagram_03())
    write_svg_png("04-health-alerts", diagram_04())
    write_svg_png("00-overview-finished", diagram_00())
    print("Done.")


if __name__ == "__main__":
    main()
