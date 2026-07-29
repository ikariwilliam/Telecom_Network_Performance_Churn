# Telecom Network Performance & Customer Churn Analysis (Lagos)

## Project Overview

Customer churn is one of the most significant challenges faced by telecommunications companies. Losing existing subscribers not only reduces recurring revenue but also increases customer acquisition costs and negatively impacts long-term profitability.

This project simulates a real-world telecom analytics environment for a fictional Lagos-based telecommunications provider. Using PostgreSQL and Power BI, it investigates how network performance, customer behavior, and customer experience contribute to subscriber churn.

The project combines multiple operational datasets—including subscriber information, network infrastructure, usage behavior, support interactions, and retention campaigns—to identify the key factors influencing customer retention and provide data-driven business recommendations.

---

# Business Problem

The telecom operator has observed increasing subscriber churn across several areas of Lagos but lacks clear visibility into the underlying causes.

Management wants to answer questions such as:

* Are customers leaving because of poor network performance?
* Can declining customer usage predict churn before it happens?
* Which regions require network investment?
* Are retention campaigns actually reducing churn?
* Which customer segments generate the highest business value?
* What operational improvements should be prioritized to improve customer retention?

The objective of this project is to answer these questions using SQL analytics and interactive Power BI dashboards.

---

# Project Objectives

The project aims to:

* Analyze subscriber churn across different customer segments.
* Evaluate the relationship between network quality and customer retention.
* Identify high-risk regions requiring network improvements.
* Measure customer value using recharge behaviour and Average Revenue Per User (ARPU).
* Evaluate customer support performance and retention campaigns.
* Produce actionable business recommendations backed by data.

---

# Business Questions

The project answers the following business questions:

## Customer Churn
* Does declining customer usage predict churn?
* Which customer segments experience the highest churn?
* Which Lagos regions have the highest churn rates?

## Network Performance
* Do subscribers in poor-network regions churn more?
* Which Lagos regions have both poor network performance and high churn?
* Which network KPIs are most strongly associated with churn?
* Which cell towers consistently underperform?
* Do network incidents increase churn?

## Revenue & Customer Value
* Does recharge behaviour change before customers churn?
* Which customer segments generate the highest Average Revenue Per User (ARPU)?

## Customer Experience
* Do customer support issues contribute to churn?
* Did retention campaigns successfully reduce churn?

---

# Project Workflow

The project follows a complete analytics workflow from business understanding through reporting.

## 1. Business Understanding
Defined the business problem, project scope, and key stakeholder questions.

## 2. Database Design
Designed a normalized PostgreSQL database representing a realistic telecom environment, including:
* Macro Regions
* Service Zones
* Cell Towers
* Subscriber Profiles
* Subscriber Status History
* Usage Records
* Network KPIs
* Network Incidents
* Recharges
* Support Tickets
* Retention Offers
* Mobile Plans

## 3. Synthetic Data Generation
A fully synthetic dataset was generated using predefined business rules to model realistic telemetry and behaviour, including:
* Declining customer usage before churn
* Network incidents causing KPI degradation
* Poor KPIs generating support tickets
* Retention campaigns targeting at-risk subscribers
* Regional differences in customer behaviour and 5G traffic variations

The final dataset contains approximately **4 million interconnected records** across multiple relational tables.

## 4. Data Validation
Before analysis, the dataset was validated using SQL (`00_data_validation.sql` and `01_data_sanity_checks.sql`) to guarantee data integrity, foreign key consistency, and realistic distribution bounds.

## 5. SQL Analytics
Business questions are answered using PostgreSQL utilizing CTEs, Window Functions, Aggregates, CASE expressions, and multi-table joins.

## 6. Power BI Dashboard
SQL outputs are visualized in interactive executive dashboards tracking churn, network performance, and customer value.

## 7. Business Recommendations
Translates analytical findings into actionable business strategies for management.

---

# Tools & Technologies

* **PostgreSQL & SQL:** Database management, data validation, and core analytics.
* **Power BI:** Executive dashboarding and visual storytelling.
* **Git & GitHub:** Version control and remote repository management.

---

# Expected Business Outcomes

* Detect customers at risk of churning before they leave.
* Prioritize network investments in high-impact locations.
* Improve customer retention through targeted interventions and campaign tracking.
* Increase customer lifetime value and recurring revenue.

---

# Disclaimer

This project uses entirely synthetic data generated for educational and portfolio purposes. While the data models realistic telecom operations and business behaviour, it does not represent any real customers or commercial telecommunications provider.

## Theme 1 — Customer Churn

### Q1: Does declining customer usage predict churn?

**Business Question:** Can reductions in calls, SMS, or mobile data usage serve as an early warning signal before a subscriber leaves?

**Approach:**
For each subscriber, an anchor date was established — their churn date (from `subscriber_status_history`) if churned, or the dataset's most recent usage date if still active. Average daily voice minutes, SMS count, and data usage (MB) were then compared across two 30-day windows relative to that anchor: the 30 days immediately prior ("recent") versus the 30 days before that ("prior"). Subscribers without a full 60 days of usage history preceding their anchor date were excluded to avoid skewing results with recent joiners. Usage was averaged per active day rather than summed, to stay robust to any missing daily records.

**Findings:**

| Segment | Subscribers | Avg Prior Voice (min/day) | Avg Recent Voice (min/day) | Voice Δ% | Avg Prior SMS (msgs/day) | Avg Recent SMS (msgs/day) | SMS Δ% | Avg Prior Data (MB/day) | Avg Recent Data (MB/day) | Data Δ% |
|---|---|---|---|---|---|---|---|---|---|---|
| Active | 84,616 | 11.99 | 12.01 | +0.2% | 2.80 | 2.81 | +0.2% | 1583.45 | 1574.12 | -0.6% |
| Churned | 6,220 | 7.31 | 2.43 | -66.7% | 1.59 | 0.20 | -87.2% | 1005.96 | 201.68 | -80.0% |

- **Active subscribers show flat usage** across both windows — no meaningful trend in voice, SMS, or data.
- **Churned subscribers show a sharp usage collapse** in the 30 days before churn: voice minutes down 66.7%, SMS down 87.2%, and data usage down 80.0%.
- **A baseline gap exists even before the collapse** — churned subscribers used less than active subscribers even in the earlier ("prior") window (e.g., 7.31 vs. 11.99 voice min/day), suggesting churners may already be lower-engagement subscribers before the acute decline begins.

**Business Implication:** Declining usage — particularly SMS and data — is a strong, detectable early-warning signal for churn, and the drop-off is steep enough to be actionable well before a subscriber is formally flagged `At Risk`. This supports building a usage-decline trigger into retention workflows rather than relying solely on status transitions to catch at-risk subscribers.

### Q2: Which customer segments experience the highest churn?

**Business Question:** Analyze churn by plan, macro region, service zone, customer tenure, age group, and gender to identify which segments are most at risk.

**Approach:**
Churn status was derived from `subscriber_status_history` (any subscriber with a `'Churned'` record). Age was bucketed into four equal-width 13-year bands (18-30, 31-43, 44-56, 57-70) based on the dataset's actual min/max age range. Tenure was calculated as days between `join_date` and either the subscriber's churn date or the dataset's fixed end date (2025-12-31, not the current date, to avoid inflating active-subscriber tenure with time outside the dataset's actual range), then grouped into standard telecom tenure bands (0-3 months, 3-6 months, 6-12 months, 1-2 years, 2+ years). ~2% of subscriber records have missing gender and age data; these were retained in totals but treated with caution in comparisons due to small, unstable sample sizes.

**Findings:**

| Dimension | Highest-Risk Segment | Lowest-Risk Segment | Spread |
|---|---|---|---|
| **Tenure** | 0-3 months (28.77%) | 2+ years (9.56%) | ~19 pts |
| **Service Zone** | Lakowe (16.97%) | Epe (11.11%*) | ~6 pts |
| **Age Band** | 57-70 (17.49%) | 18-30 (15.22%) | ~2 pts |
| **Macro Region** | Lagos Island (15.54%) | Ikorodu Axis (14.99%) | ~0.5 pts |
| **Plan / Gender** | Business Lite Postpaid (~16.7%) | Unlimited 5G Postpaid (~15%) | ~1.5 pts |

*Epe has only 207 subscribers — treat as a small-sample outlier, not a strong signal.

- **Tenure is by far the strongest churn driver.** Churn risk starts at 28.77% in the first 3 months and declines steadily to 9.56% for subscribers with 2+ years of tenure — a ~3x spread. This is a classic early-lifecycle churn curve: new subscribers are the highest-risk group by a wide margin.
- **Geography (service zone) shows moderate spread**, with Lakowe (16.97%) and Ogba/Ojodu (16.46%) as the highest-churn zones, and Epe (11.11%, small-N) and Ibeju-Lekki (13.95%) the lowest. Macro region alone is nearly flat, meaning churn variation is more local (zone-level) than regional.
- **Age shows a mild upward trend** — older subscribers churn slightly more often (57-70: 17.49%) than younger ones (18-30: 15.22%), but the spread is modest compared to tenure.
- **Plan and gender are weak differentiators.** Nearly all plan/gender combinations cluster in a 12-17% churn band, suggesting these attributes don't meaningfully predict churn on their own in this dataset.

**Business Implication:** Retention efforts should prioritize the first 6-12 months of the subscriber lifecycle, where churn risk is 2-3x higher than the base rate — this is where onboarding, early engagement campaigns, and proactive retention offers would have the most impact. Service-zone-level targeting (rather than broad regional campaigns) is also worth pursuing, since churn varies more by local zone than by macro region. Plan type and gender are not useful segmentation variables for churn risk on their own.

### Q3: Which Lagos regions and service zones have the highest churn rates?

**Business Question:** Identify geographical hotspots where customer losses are concentrated, and determine whether churn varies between macro regions and their service zones.

**Approach:**
Rather than ranking purely by churn rate, this analysis distinguishes between churn **rate** (risk within a segment) and churn **volume share** (that segment's contribution to total churned subscribers company-wide). A zone can have an alarming rate but negligible business impact if it's small, or a middling rate but be a major hotspot simply due to its size. Both metrics are reported, with zones also ranked within their parent macro region.

**Findings:**

*Region-level (by volume share of total churn):*

| Region | Subscribers | Churned | Churn Rate | % of All Churn |
|---|---|---|---|---|
| Lagos Island | 25,266 | 3,926 | 15.54% | 25.52% |
| Central Mainland | 25,027 | 3,862 | 15.43% | 25.10% |
| Western Mainland | 21,744 | 3,327 | 15.30% | 21.63% |
| Northern Mainland | 19,856 | 3,054 | 15.38% | 19.85% |
| Ikorodu Axis | 8,107 | 1,215 | 14.99% | 7.90% |

*Zone-level — rate vs. volume diverge:*

| Metric | Top Zone | Value |
|---|---|---|
| Highest churn **rate** | Lakowe | 16.97% (but only 501 subscribers — 0.55% of total churn) |
| Highest churn **volume share** | Alimosho/Ikotun | 8.61% of all churned subscribers (rate: 14.86% — below average) |
| 2nd highest volume share | Ikeja (CBD & GRA) | 8.00% (rate: 15.15%) |
| 3rd highest volume share | Ikorodu Core | 7.90% (rate: 14.99%) |

- **Region-level churn rates are nearly flat** (14.99%–15.54% across all 5 regions), consistent with the Q2 finding — churn isn't concentrated by broad region.
- **Zone-level rate and volume tell different stories.** The zones with the highest churn *rates* (Lakowe, Ogba/Ojodu) are small subscriber bases and contribute little to total churn volume. The zones with the largest *volume share* (Alimosho/Ikotun, Ikeja CBD & GRA, Ikorodu Core) actually have average or below-average churn rates — they matter simply because of their size.
- **This is a classic rate-vs-volume trap.** A retention team chasing the highest-rate zones would spend resources on Lakowe (85 churned subscribers total) while missing Alimosho/Ikotun (1,324 churned subscribers) — nearly 16x more customers lost, at a lower headline rate.

**Business Implication:** Retention investment should prioritize **volume-share hotspots** (Alimosho/Ikotun, Ikeja CBD & GRA, Ikorodu Core, Lekki Phase 1) for maximum customer-retention impact, while treating high-rate/low-volume zones like Lakowe as worth monitoring but not urgent — fixing them saves few customers in absolute terms. Region-level targeting is not useful on its own since churn rate is nearly uniform across macro regions; the real signal is at the zone level.

### Q4: How does subscriber status evolve before churn?

**Business Question:** Using subscriber_status_history — how long do subscribers remain "At Risk" before churning? Do customers recover after receiving retention offers? What is the most common lifecycle leading to churn?

**Approach:**
Each subscriber's full status history was traced in chronological order to reconstruct their lifecycle path (e.g., `Active -> At Risk -> Retention Offered -> Churned`). Time-at-risk was measured as days between a subscriber's first "At Risk" status and their eventual "Churned" status. Retention offer outcomes were assessed by checking each offered subscriber's most recent status.

**Findings:**

*Time at risk before churn:*

| Metric | Value |
|---|---|
| Churned subscribers with At Risk history | 15,384 |
| Average days at risk before churn | 21.4 |
| Median days | 21 |
| Range | 14–29 days |

*Outcome after retention offer:*

| Outcome | Subscribers | % of Offered |
|---|---|---|
| Churned anyway | 11,119 | 83.23% |
| Recovered | 1,806 | 13.52% |
| Still pending (Retention Offered, no outcome yet) | 435 | 3.26% |

*Most common lifecycle paths:*

| Outcome | Path | Subscribers | % within outcome |
|---|---|---|---|
| Churned | Active → At Risk → Retention Offered → Churned | 11,119 | 72.28% |
| Churned | Active → At Risk → Churned | 4,265 | 27.72% |
| Active | Active (never at risk) | 82,201 | 97.15% |
| Active | Active → At Risk → Retention Offered → Recovered | 1,806 | 2.13% |
| Active | Active → At Risk → Retention Offered (pending) | 435 | 0.51% |
| Active | Active → At Risk (pending) | 174 | 0.21% |

- **The risk-to-churn window is short and consistent** — a median of 21 days, tightly bound between 14 and 29 days. This is a narrow, predictable window for intervention.
- **Retention offers have a low success rate.** Only 13.52% of offered subscribers recovered; the large majority (83.23%) churned regardless of the offer.
- **Most churners were reached, but not retained.** 72.28% of all churned subscribers did receive a retention offer before leaving — so the gap isn't primarily about *detection* or *outreach coverage*, it's about *offer effectiveness*. A smaller share (27.72%) churned without ever reaching the offer stage, which may point to a secondary gap in reaction speed for a subset of at-risk subscribers.

**Business Implication:** The 14–29 day at-risk window is short, meaning retention workflows need to trigger quickly once a subscriber is flagged. But the bigger issue this data reveals is offer *quality*, not offer *timing* — since most churners were already reached with an offer and left anyway, the business should prioritize testing better-targeted or higher-value retention offers over simply widening outreach. The current offer program is reaching people; it isn't convincing them to stay.