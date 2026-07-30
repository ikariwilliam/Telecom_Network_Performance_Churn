# Telecom Network Performance & Customer Churn Analysis (Lagos)

## Table of Contents
- [Project Overview](#project-overview)
- [Business Problem](#business-problem)
- [Executive Summary](#executive-summary)
- [Project Objectives](#project-objectives)
- [Business Questions](#business-questions)
- [Project Workflow](#project-workflow)
- [Tools & Technologies](#tools--technologies)
- [Theme 1 — Customer Churn](#theme-1--customer-churn)
- [Theme 2 — Network Performance](#theme-2--network-performance)
- [Theme 3 — Revenue & Customer Value](#theme-3--revenue--customer-value)
- [Theme 4 — Customer Experience & Retention](#theme-4--customer-experience--retention)
- [Key Findings](#key-findings)
- [Business Recommendations](#business-recommendations)
- [Data Limitations](#data-limitations)
- [Expected Business Outcomes](#expected-business-outcomes)
- [Disclaimer](#disclaimer)

---

## Project Overview

Customer churn is one of the most significant challenges faced by telecommunications companies. Losing existing subscribers not only reduces recurring revenue but also increases customer acquisition costs and negatively impacts long-term profitability.

This project simulates a real-world telecom analytics environment for a fictional Lagos-based telecommunications provider. Using PostgreSQL and Power BI, it investigates how network performance, customer behavior, and customer experience contribute to subscriber churn.

The project combines multiple operational datasets—including subscriber information, network infrastructure, usage behavior, support interactions, and retention campaigns—to identify the key factors influencing customer retention and provide data-driven business recommendations.

---

## Business Problem

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

## Executive Summary

Across 13 business questions spanning churn, network performance, revenue, and customer experience, one consistent pattern emerged: **churn in this dataset is driven by subscriber behavior, not service quality.** Declining usage (Q1) and declining recharge activity (Q10) both collapse sharply — by 80%+ — in the 30 days before a subscriber churns, and short-tenure subscribers churn at nearly 3x the rate of long-tenure ones (Q2). By contrast, network quality (Q5, Q7) and support ticket experience (Q12) show virtually no relationship with churn at the dataset-wide level, with one notable localized exception (Lakowe and Tower 319, flagged in Q6/Q8/Q9). Retention offers reach the majority of at-risk subscribers (72% of churners received one, Q4) but convert poorly — even accepted offers only retain 1 in 4 subscribers (Q13), pointing to an offer-effectiveness problem rather than an outreach or detection gap. Plan tier is by far the strongest revenue differentiator (a ~30x ARPU spread, Q11), and premium-plan subscribers also churn less, suggesting retention and upsell strategies could be combined.

---

## Project Objectives

The project aims to:

* Analyze subscriber churn across different customer segments.
* Evaluate the relationship between network quality and customer retention.
* Identify high-risk regions requiring network improvements.
* Measure customer value using recharge behaviour and Average Revenue Per User (ARPU).
* Evaluate customer support performance and retention campaigns.
* Produce actionable business recommendations backed by data.

---

## Business Questions

The project answers the following business questions:

### Customer Churn
* Does declining customer usage predict churn?
* Which customer segments experience the highest churn?
* Which Lagos regions and service zones have the highest churn rates?
* How does subscriber status evolve before churn?

### Network Performance
* Do subscribers in poor-network regions churn more?
* Which Lagos regions and service zones have both poor network performance and high churn?
* Which network KPIs are most strongly associated with churn?
* Which cell towers consistently underperform?
* Do network incidents increase churn?

### Revenue & Customer Value
* Does recharge behaviour change before customers churn?
* Which customer segments generate the highest Average Revenue Per User (ARPU)?

### Customer Experience & Retention
* Do customer support issues contribute to churn?
* Did retention campaigns successfully reduce churn?

---

## Project Workflow

The project follows a complete analytics workflow from business understanding through reporting.

### 1. Business Understanding
Defined the business problem, project scope, and key stakeholder questions.

### 2. Database Design
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

### 3. Synthetic Data Generation
A fully synthetic dataset was generated using predefined business rules to model realistic telemetry and behaviour, including:
* Declining customer usage before churn
* Network incidents causing KPI degradation
* Poor KPIs generating support tickets
* Retention campaigns targeting at-risk subscribers
* Regional differences in customer behaviour and 5G traffic variations

The final dataset contains approximately **4 million interconnected records** across multiple relational tables.

### 4. Data Validation
Before analysis, the dataset was validated using SQL (`00_data_validation.sql` and `01_data_sanity_checks.sql`) to guarantee data integrity, foreign key consistency, and realistic distribution bounds.

### 5. SQL Analytics
Business questions are answered using PostgreSQL utilizing CTEs, Window Functions, Aggregates, CASE expressions, and multi-table joins.

### 6. Power BI Dashboard
SQL outputs are visualized in interactive executive dashboards tracking churn, network performance, and customer value.

### 7. Business Recommendations
Translates analytical findings into actionable business strategies for management.

---

## Tools & Technologies

* **PostgreSQL & SQL:** Database management, data validation, and core analytics.
* **Power BI:** Executive dashboarding and visual storytelling.
* **Git & GitHub:** Version control and remote repository management.

---

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

---

## Theme 2 — Network Performance

### Q5: Do subscribers in poor-network regions churn more?

**Business Question:** Determine whether poor service quality is associated with higher customer churn.

**Approach:**
Each subscriber's home tower's network KPIs (signal strength, dropped call rate, latency, packet loss, availability) were averaged across the full dataset period, then compared between churned and active subscribers.

**Findings:**

| Metric | Active Subscribers | Churned Subscribers |
|---|---|---|
| Subscriber count | 84,616 | 15,384 |
| Avg Signal Strength (RSRP, dBm) | -95.01 | -95.02 |
| Avg Dropped Call Rate (%) | 1.03 | 1.03 |
| Avg Latency (ms) | 38.59 | 38.58 |
| Avg Packet Loss (%) | 0.93 | 0.93 |
| Avg Availability (%) | 98.37 | 98.37 |

- **No meaningful difference in lifetime-average network quality** between churned and active subscribers across any KPI.
- **Important caveat:** this analysis uses each tower's *full-period* average KPI, which likely dilutes short-term network degradation (e.g., a bad month right before a subscriber churns gets averaged against years of normal performance). A tower-lifetime average is not the same as "the network quality this subscriber actually experienced leading up to their churn decision."

**Business Implication:** At the lifetime-average level, network quality does not appear to be a broad churn driver — this by itself doesn't support a blanket "invest in weak towers" strategy. However, this finding should not be read as "network quality never matters" — it specifically means *long-run average* quality isn't the driver. Q6 (regional quality vs. churn) and Q9 (network incidents vs. churn timing) will test whether *localized* or *time-proximate* network problems tell a different story than the lifetime average does.

### Q6: Which regions and service zones have both poor network performance and high churn?

**Business Question:** Combine network KPIs with churn rates to identify priority investment zones.

**Approach:**
Network KPIs were aggregated to the service zone level (across all towers in each zone) and combined with the zone-level churn rates from Q3. Zones were ranked separately on churn rate, dropped call rate, and availability, then a combined rank score (sum of the three individual ranks) was used to surface zones performing poorly on all three dimensions simultaneously — not just one metric in isolation.

**Findings:**

| Zone | Region | Churn Rate | Churn Rank | Dropped Call Rate | Availability | Combined Score |
|---|---|---|---|---|---|---|
| **Lakowe** | Lagos Island | 16.97% | 1 | 1.08% | 98.21% | **3** |
| Victoria Island | Lagos Island | 15.82% | 6 | 1.05% | 98.35% | 14 |
| Surulere | Central Mainland | 16.39% | 3 | 1.04% | 98.35% | 14 |
| Festac/Amuwo-Odofin | Western Mainland | 15.88% | 5 | 1.04% | 98.35% | 16 |

- **Lakowe is a genuine, isolated hotspot** — it ranks #1 (worst) on churn rate, #1 (worst) on dropped call rate, and #1 (worst) on availability, giving it a combined score of 3, far ahead of the next-worst zone (score 14).
- **The effect size is modest, not dramatic.** Lakowe's dropped call rate (1.08%) is only marginally worse than the 8th-10th ranked zones (1.03-1.04%), and its availability (98.21%) is close to the others (98.32-98.36%). Lakowe is consistently the worst performer, but by a small margin — this is a real signal, not a severe outage.
- **This reconciles with Q5's null result.** Q5 found no subscriber-level correlation between network quality and churn because that signal gets diluted across 26 zones of mostly-similar performance. Q6 shows that aggregating to the zone level surfaces one real (if modest) pattern that individual-subscriber averaging washed out.

**Business Implication:** Lakowe is the clearest candidate for network infrastructure investment — it's the only zone where poor network quality and high churn consistently co-occur. However, given the modest gap in absolute KPI terms, this should be treated as a monitoring priority and a candidate for deeper investigation (e.g., checking `network_incidents` for Lakowe specifically) rather than a zone requiring emergency intervention.

### Q7: Which network KPIs have the strongest relationship with churn?

**Business Question:** Compare metrics such as dropped call rate, signal strength, latency, and packet loss to determine which most strongly correlates with customer loss.

**Approach:**
Pearson correlation coefficients were computed between each subscriber's home-tower lifetime-average KPI and their churn outcome (coded as 1/0).

**Findings:**

| KPI | Correlation with Churn |
|---|---|
| Signal Strength (RSRP) | -0.0034 |
| Dropped Call Rate | -0.0008 |
| Latency | -0.0017 |
| Packet Loss | 0.0021 |
| Availability | -0.0002 |

- **None of the five network KPIs show any meaningful linear relationship with churn.** Every coefficient is within ±0.0034 of zero — for reference, correlations are generally not considered meaningful until they exceed roughly ±0.1, so these are an order of magnitude below any usable threshold.
- **This confirms and quantifies Q5's finding.** At the lifetime-average, subscriber level, network quality is not a churn driver in this dataset — full stop.

**Business Implication:** Lifetime-average network KPIs at a subscriber's home tower are not a useful churn predictor and should not be used as a standalone input to churn risk models. This reinforces the Q6 finding that network-related churn (where it exists, as with Lakowe) is a localized, zone-specific pattern — not a broad, dataset-wide relationship. Combined with Q1's finding that *usage decline* is a strong predictor, this suggests churn in this dataset is driven primarily by subscriber behavior, not infrastructure quality.

### Q8: Which cell towers consistently underperform?

**Business Question:** Identify towers with recurring poor KPIs or repeated network incidents to prioritize maintenance or upgrades.

**Approach:**
Each tower was ranked independently on three dimensions — dropped call rate, availability, and total incident count — then combined into a single underperformance score (sum of the three ranks) to surface towers with a persistent, multi-dimensional pattern of poor performance rather than a single bad metric or one-off event.

**Findings:**

| Tower | Zone | Region | Tech | Dropped Call Rate | Availability | Total Incidents | High-Severity Incidents | Downtime (hrs) | Combined Score |
|---|---|---|---|---|---|---|---|---|---|
| **319** | Ikeja (CBD & GRA) | Central Mainland | 4G | 1.13% | 97.80% | 22 | 4 | 198 | **36** |
| 33 | Victoria Island | Lagos Island | 4G | 1.17% | 98.01% | 16 | 2 | 89 | 112 |
| 247 | Lakowe | Lagos Island | 5G | 1.10% | 98.02% | 18 | 3 | 90 | 127 |
| 459 | Ebute Metta | Central Mainland | 4G | 1.10% | 98.08% | 20 | 5 | 193 | 130 |

- **Tower 319 (Ikeja CBD & GRA) is a clear, isolated worst performer** — its combined score (36) is more than 3x worse than the next tower (112), and it leads on every individual metric: highest dropped call rate, lowest availability, most incidents overall, and most high-severity incidents.
- **Lakowe's tower (247) also appears here**, consistent with it being flagged as a churn/network hotspot in Q6 — reinforcing that Lakowe's issue isn't isolated to one KPI snapshot but shows up independently in incident-based analysis too.
- **Ikeja (CBD & GRA) is notable for a different reason:** it was also the 2nd-largest contributor to total churn volume in Q3 (8.00% of all churned subscribers). Given Q7 found no dataset-wide correlation between network KPIs and churn, this overlap should be treated as worth investigating further, not as proof the tower's poor performance is driving churn there.

**Business Implication:** Tower 319 (Ikeja CBD & GRA) should be the top priority for infrastructure investment — it's a consistent, multi-dimensional underperformer with the highest downtime in the dataset. Lakowe's tower is a secondary priority, consistent with earlier findings. Given the overlap between Ikeja's poor network performance and its high churn volume, a targeted before/after analysis of that specific tower (rather than the dataset-wide averages used in Q5/Q7) could clarify whether localized infrastructure investment there would meaningfully reduce churn.

### Q9: Do network incidents increase churn?

**Business Question:** Measure whether outages, congestion, or other service disruptions are followed by higher churn in the affected service zones.

**Approach:**
Each subscriber was flagged as having had a network incident at their home tower within the 30 days before their anchor date (churn date, or dataset end for active subscribers).

**Data limitation discovered during analysis:** `network_incidents` contains records exclusively from 2025 — no incidents are logged for 2018-2024, despite towers being installed steadily across that period. An initial version of this query compared all subscribers regardless of anchor date, which produced a misleading result (subscribers with incidents appeared to churn *less*) purely because active subscribers are anchored to Dec 2025 by default and therefore had the only realistic chance of falling within the incident-logging window, while most churned subscribers left before 2025 and could never register an incident regardless of what happened at their tower. The analysis below is restricted to subscribers whose anchor date falls in 2025, so both groups are drawn from the same time period where incident data actually exists.

**Findings:**

| Had Incident in Prior 30 Days | Subscribers | Churned | Churn Rate |
|---|---|---|---|
| Yes | 53,125 | 4,294 | 8.08% |
| No | 38,478 | 2,693 | 7.00% |

- **Subscribers with a recent network incident at their home tower churned at a modestly higher rate** (8.08% vs. 7.00%) — a ~1.08 percentage point, or roughly 15% relative, increase.
- This is a small but directionally consistent effect, and lines up with earlier findings: Lakowe (Q6) and Ikeja CBD & GRA (Q8) were both flagged as towers/zones with elevated incident activity and elevated churn.

**Business Implication:** Network incidents do appear to modestly raise short-term churn risk, though the effect is smaller than either usage decline (Q1) or tenure (Q2). Given the data quality issue uncovered here — incidents only being logged for 2025 — this finding should be treated as directionally suggestive rather than statistically definitive; a fuller incident history across all years would allow a more robust test.

---

## Theme 3 — Revenue & Customer Value

### Q10: Does recharge behaviour change before customers churn?

**Business Question:** Determine whether customers begin recharging less frequently or spending less before leaving.

**Approach:**
Same methodology as Q1 — recharge count and total amount were compared across two 30-day windows relative to each subscriber's anchor date (churn date, or dataset end for active subscribers). Subscribers without at least 60 days of recharge history before their anchor date were excluded.

**Findings:**

| Segment | Subscribers | Avg Prior Recharges | Avg Recent Recharges | Count Δ% | Avg Prior Amount (₦) | Avg Recent Amount (₦) | Amount Δ% |
|---|---|---|---|---|---|---|---|
| Active | 44,787 | 0.07 | 0.07 | -1.4% | 418.06 | 418.88 | +0.2% |
| Churned | 2,290 | 0.05 | 0.01 | -83.6% | 257.42 | 46.72 | -81.8% |

- **Active subscribers show flat recharge behavior** across both windows — consistent with the flat usage pattern from Q1.
- **Churned subscribers show a sharp recharge collapse** in the 30 days before churn — frequency down 83.6%, spend down 81.8%. This mirrors the usage-decline pattern from Q1 almost exactly in magnitude.
- **A baseline gap exists even before the collapse**, same as Q1 — churned subscribers recharged less often and spent less even in the earlier window (0.05 vs. 0.07 recharges; ₦257 vs. ₦418), suggesting lower engagement precedes the acute drop-off.

**Data limitation:** Fewer than half of all subscribers (47,077 of 100,000) had sufficient recharge history (60+ days before their anchor date) to qualify for this comparison, since recharges are sparse and irregular compared to daily usage records. This finding is directionally strong but reflects the more active/frequent-recharging portion of the subscriber base rather than the full population.

**Business Implication:** Recharge behavior is a second strong, independently-confirming early warning signal alongside usage decline (Q1) — both usage and revenue-generating behavior collapse in tandem shortly before churn. This reinforces that a combined usage-and-recharge decline trigger would be a strong candidate for a proactive retention system, since the two signals corroborate each other rather than relying on just one metric.

### Q11: Which customer segments generate the highest ARPU?

**Business Question:** Compare revenue across plans, macro regions, service zones, customer tenure, and age groups to identify the most valuable subscriber segments.

**Approach:**
Revenue was measured via total recharge amount per subscriber (the only revenue signal available in this schema — there is no separate postpaid billing table). For plan, region, zone, and age, monthly ARPU (total revenue ÷ tenure in months) was calculated and averaged per segment. For tenure itself, monthly-rate extrapolation was found to be misleading (see note below) and total lifetime revenue is reported instead.

**Data investigation note:** An initial tenure-band ARPU calculation showed 0-3 month subscribers with ~30x higher "monthly ARPU" than 2+ year subscribers. Investigation showed this wasn't a real spending difference — recharge count (~0.7-0.8 recharges) and total revenue (~₦3,769-4,737) are nearly identical across all tenure bands. The apparent gap was purely a division artifact: similar total revenue divided by a much smaller tenure-in-months denominator for newer subscribers mechanically inflates their extrapolated "monthly rate." Recharge revenue in this dataset does not scale with tenure, so a monthly-rate framing was dropped in favor of reporting raw totals for this dimension.

**Findings:**

*By Plan (strongest differentiator):*

| Plan | Subscribers | Avg Monthly ARPU (₦) |
|---|---|---|
| Enterprise Max | 998 | 4,652.80 |
| Unlimited 5G | 1,989 | 3,846.83 |
| Business Pro | 5,081 | 2,150.75 |
| Business Lite | 6,001 | 1,099.59 |
| Smart Plus | 18,048 | 159.07 |
| Smart Lite | 34,908 | 158.19 |
| Smart Standard | 24,974 | 153.14 |
| Max Data | 8,001 | 150.52 |

*By Macro Region (weak differentiator, ₦416-469 range):*
Northern Mainland highest (₦469.38), Central Mainland lowest (₦415.86) — roughly flat.

*By Age Band (weak differentiator, ₦405-534 range):*
Unknown/null-age group highest (₦534.29, small-N caveat), 44-56 highest of known bands (₦462.51), 57-70 lowest (₦405.22).

*By Service Zone (moderate spread, ₦307-592 range):*
Ibeju-Lekki highest (₦592.18), Ajah lowest (₦307.31) — no obvious geographic clustering pattern.

*By Tenure (total lifetime revenue, not monthly rate):*

| Tenure Band | Subscribers | Avg Recharge Count | Avg Total Revenue (₦) | Avg per Recharge (₦) |
|---|---|---|---|---|
| 0-3 months | 5,869 | 0.72 | 4,347.16 | 6,042.99 |
| 3-6 months | 7,596 | 0.75 | 4,294.30 | 5,757.06 |
| 6-12 months | 13,704 | 0.77 | 4,341.62 | 5,622.52 |
| 1-2 years | 11,921 | 0.69 | 3,769.31 | 5,485.78 |
| 2+ years | 59,799 | 0.81 | 4,736.68 | 5,867.88 |

- **Plan tier is overwhelmingly the strongest revenue driver** — roughly a 30x spread between Enterprise Max/Unlimited 5G and the entry-level plans, far larger than any churn-related dimension we've examined.
- **Recharge behavior is essentially flat across tenure**, both in count (~0.7-0.8 recharges) and total spend (~₦3,769-4,737) — tenure does not meaningfully predict how much a subscriber recharges.
- **Region, zone, and age are all weak-to-moderate differentiators**, consistent with their role throughout this analysis (they mattered little for churn either).

**Business Implication:** Plan tier is the clear revenue lever — upselling subscribers from entry plans (Smart Lite/Standard/Max Data, ~₦150-160/month) toward mid/premium tiers (Business Pro, Unlimited 5G, Enterprise Max) would have far more revenue impact than any geographic or demographic targeting strategy. Since high-value plans (Business Pro, Enterprise Max) also had among the lowest churn rates in Q2, retention and upsell efforts could reasonably be combined — premium-plan subscribers appear to be both more valuable and more stable.

---

## Theme 4 — Customer Experience & Retention

### Q12: Do customer support issues contribute to churn?

**Business Question:** Evaluate whether customers who raise support tickets are more likely to churn, and whether issue type or resolution time influences retention.

**Approach:**
Three tests were run: (1) churn rate comparing subscribers who ever raised a ticket vs. those who never did, (2) churn rate broken down by issue type, and (3) average ticket resolution time compared between churned and active subscribers.

**Findings:**

*Any ticket vs. none:*

| Had a Ticket | Subscribers | Churned | Churn Rate |
|---|---|---|---|
| Yes | 69,730 | 10,818 | 15.51% |
| No | 30,270 | 4,566 | 15.08% |

*By issue type:*

| Issue Type | Subscribers | Churned | Churn Rate |
|---|---|---|---|
| Account Issue | 5,887 | 956 | 16.24% |
| Billing | 16,297 | 2,585 | 15.86% |
| Network Outage | 11,152 | 1,735 | 15.56% |
| Poor Signal | 30,310 | 4,711 | 15.54% |
| Slow Internet | 30,247 | 4,630 | 15.31% |
| SIM Replacement | 11,430 | 1,742 | 15.24% |

*Resolution time:*

| | Subscribers | Avg Resolution Time (hrs) |
|---|---|---|
| Active | 57,811 | 21.98 |
| Churned | 10,616 | 21.88 |

- **Raising a support ticket has almost no effect on churn** — a 0.43 point gap, well within the range of normal segment-to-segment noise seen throughout this analysis.
- **Issue type shows minimal spread** (15.24%–16.24%), with Account Issue slightly elevated but based on the smallest subscriber group among the six categories, so this should not be treated as a strong finding without further evidence.
- **Resolution speed does not predict churn** — churned and active subscribers experienced almost identical average resolution times.

**Business Implication:** Customer support interactions, in this dataset, are not a meaningful churn driver — neither having a support issue at all, the type of issue, nor how quickly it was resolved shows a real relationship with churn. This reinforces the pattern established in Theme 2: churn in this dataset is driven by subscriber behavior (usage and recharge decline, tenure) rather than service-quality touchpoints like network incidents or support experience.

### Q13: Did retention offers successfully reduce churn?

**Business Question:** Measure the effectiveness of different retention campaigns and identify which customer segments responded best. Evaluate offer acceptance rate, churn after offer, and retention by offer type.

**Approach:**
Retention offer outcomes were evaluated four ways: by offer type, by delivery channel, by the offer's own accepted/rejected status, and by whether acceptance actually predicts recovery.

**Findings:**

*Overall acceptance rate:*

| Offer Status | Count | % of Offers |
|---|---|---|
| Accepted | 7,296 | 54.61% |
| Rejected | 6,064 | 45.39% |

*Does acceptance predict recovery:*

| Offer Status | Subscribers | Recovered | Churned | Recovery Rate |
|---|---|---|---|---|
| Accepted | 7,296 | 1,806 | 5,259 | 24.75% |
| Rejected | 6,064 | 0 | 5,860 | 0.00% |

*By offer type (recovery rate, all offers):*

| Offer Type | Subscribers Offered | Recovered | Recovery Rate |
|---|---|---|---|
| Bonus Data | 2,663 | 383 | 14.38% |
| Loyalty Upgrade | 2,627 | 375 | 14.27% |
| Device Upgrade | 2,677 | 362 | 13.52% |
| Discount | 2,710 | 365 | 13.47% |
| Free Minutes | 2,683 | 321 | 11.96% |

*By offer channel (recovery rate, all offers):*

| Channel | Subscribers Offered | Recovered | Recovery Rate |
|---|---|---|---|
| Call Center | 3,339 | 462 | 13.84% |
| SMS | 3,238 | 442 | 13.65% |
| App | 3,350 | 452 | 13.49% |
| Email | 3,433 | 450 | 13.11% |

- **Acceptance is necessary but not sufficient for recovery.** No rejected offer ever resulted in recovery (0.00%), confirming that acceptance is a hard prerequisite. But even among subscribers who accepted, three-quarters (75.25%) still churned — accepting an offer is far from a guarantee of retention.
- **Offer type and channel both show only mild spread** (11.96%–14.38% for type, 13.11%–13.84% for channel), with Bonus Data and Loyalty Upgrade performing marginally better, and Free Minutes and Email trending weakest. None of these differences are large enough to call one offer type or channel clearly superior.
- **The real bottleneck is the acceptance-to-recovery conversion, not offer design.** Since type and channel barely move the needle, the retention program's core weakness isn't which offer is sent or how — it's that even a "successful" (accepted) interaction only saves about 1 in 4 subscribers.

**Business Implication:** The retention offer program's biggest lever isn't offer type or delivery channel — both already convert similarly. The real opportunity is improving what happens *after* acceptance, since 75% of subscribers who said yes to an offer still left. This might point to offer value being insufficient (subscribers accept but aren't satisfied enough to stay) or to underlying issues (the same usage/recharge decline from Q1/Q10) that a one-time offer doesn't actually resolve. Combined with Q4's finding that most churners were reached with an offer (72.28%) but still left, this dataset consistently points to offer *effectiveness*, not offer *reach* or *type*, as the core retention gap.

---

## Key Findings

**Behavioral signals predict churn; service-quality signals mostly don't.**
Usage decline (Q1), recharge decline (Q10), and tenure (Q2) were the three strongest churn predictors found in this analysis, each showing large, consistent effects. Network KPIs (Q5, Q7) and support ticket experience (Q12) showed no meaningful relationship with churn at the subscriber level — a finding that held up even after controlling for confounds like tenure and time-period artifacts.

**Where network quality does matter, it's localized, not systemic.**
Q6 and Q8 both independently flagged Lakowe (zone) and Tower 319 in Ikeja CBD & GRA as consistent underperformers on network KPIs and incidents — and Ikeja also ranked among the highest-volume churn contributors (Q3). Q9 confirmed a modest (~1 point) churn increase following nearby incidents, once a data quality issue (incidents only logged for 2025) was corrected. This suggests network quality is a real but narrow driver, concentrated in specific infrastructure, not a broad churn cause.

**Retention offers reach people but don't convert.**
72.28% of churned subscribers received a retention offer before leaving (Q4), and 54.61% of all offers were accepted (Q13) — so outreach and acceptance aren't the bottleneck. But even accepted offers only produced a 24.75% recovery rate, and offer type/channel showed minimal differentiation (Q13). The gap is in offer effectiveness, not offer reach.

**Revenue and churn both concentrate around plan tier.**
Plan generated the widest spread seen in either churn or revenue analysis — premium plans (Enterprise Max, Unlimited 5G) showed both meaningfully lower churn (Q2) and ~30x higher ARPU (Q11) than entry-level plans, making plan tier the single most commercially significant segment in the dataset.

**Geography matters more at the zone level than the region level.**
Macro region was consistently flat across every dimension tested (churn, revenue, network quality). Service zone showed real, if moderate, variation — meaning localized, zone-level strategy is more actionable than broad regional campaigns.

---

## Business Recommendations

1. **Build a usage + recharge decline early-warning trigger.** (Q1, Q10) Since both signals collapse sharply and in tandem before churn, a combined-decline threshold could flag at-risk subscribers earlier and more reliably than waiting for formal "At Risk" status assignment.

2. **Redesign the retention offer value proposition, not the outreach process.** (Q4, Q13) Outreach and acceptance are already high; the failure point is post-acceptance retention. Investigate whether offers address the subscriber's actual reason for leaving, or test higher-value/longer-duration offers against the current set.

3. **Prioritize the first 6-12 months of the subscriber lifecycle for retention investment.** (Q2) Churn risk is 2-3x higher in this window than the 2+ year baseline — onboarding and early engagement programs would target the highest-risk period directly.

4. **Direct infrastructure investment to Tower 319 (Ikeja CBD & GRA) and Lakowe.** (Q6, Q8, Q9) These are the only consistent, multi-metric network underperformers in the dataset, and both show early signs of an associated churn effect.

5. **Use zone-level, not region-level, targeting for any geographic strategy.** (Q3, Q6, Q11) Macro region is consistently flat across churn, network quality, and revenue; meaningful variation only appears at the service zone level.

6. **Pair retention efforts with upsell strategy on premium plans.** (Q2, Q11) Premium-plan subscribers are both lower-churn and higher-revenue, making plan upgrade campaigns a dual-purpose lever rather than a tradeoff between retention and revenue goals.

7. **Deprioritize network- and support-experience-based churn interventions at the broad level.** (Q5, Q7, Q12) Neither shows a dataset-wide churn relationship; resources aimed at "improving network quality to reduce churn" or "improving support resolution speed to reduce churn" are unlikely to move the needle outside the specific towers/zones already flagged.

---

## Data Limitations

- **Network incidents are only logged for 2025** — no incident records exist for 2018-2024, despite towers being installed steadily across that period. Q9's analysis was restricted to subscribers with a 2025 anchor date to avoid a misleading result caused by this gap; a fuller incident history would allow a more robust test of incident-churn timing.
- **Recharges are the only available revenue signal.** This schema has no separate postpaid billing/subscription table, so recharge spend was used as a revenue proxy for both prepaid and postpaid subscribers in Q10 and Q11. This likely understates true postpaid revenue, which would typically be dominated by a recurring monthly fee rather than ad hoc recharges.
- **~2% of subscriber records have missing gender and age data** (2,041 and 1,984 subscribers respectively). These were retained in overall totals but excluded from gender- and age-specific comparisons due to small, unstable sample sizes.
- **Recharge history is sparse for a large share of subscribers.** Fewer than half of all subscribers (47,077 of 100,000) had sufficient recharge history (60+ days) to qualify for the before/after comparison in Q10, since recharges are infrequent, irregular events rather than daily activity.

---

## Expected Business Outcomes

Based on the findings above, this analysis supports the following outcomes if acted on:

* **Earlier churn detection** — a combined usage-and-recharge decline trigger (Q1, Q10) can flag at-risk subscribers before formal "At Risk" status is assigned, within the narrow 14-29 day risk-to-churn window identified in Q4.
* **Targeted, not blanket, network investment** — infrastructure spend directed at the specific underperforming assets identified (Tower 319, Lakowe) rather than broad regional rollouts, since network quality was not found to be a systemic churn driver.
* **A retention program redesigned around offer effectiveness** — since outreach and acceptance are already high but post-acceptance recovery is low (24.75%), improving offer value and follow-through stands to meaningfully increase the number of retained subscribers per offer sent, rather than requiring more offers to be sent.
* **Increased customer lifetime value through plan-tier strategy** — combining retention and upsell efforts around premium plans, which this analysis found to be both lower-churn and substantially higher-revenue.

---

## Disclaimer

This project uses entirely synthetic data generated personally for educational and portfolio purposes. While the data models realistic telecom operations and business behaviour, it does not represent any real customers or commercial telecommunications provider.