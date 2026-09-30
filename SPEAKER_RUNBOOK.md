# Speaker runbook — 60 minutes

## 0–5 — Hook
Show `kubectl get pods`: everything Running. Trigger the slow request.
Ask: **“Everything is Running. Where did the user's time go?”**

## 5–15 — Kubernetes-native investigation
Use `get pods`, `svc`, `events`, `logs`, `top`. Establish that the workload is alive and routable.

## 15–25 — Distributed tracing
Open Jaeger (or your Elastic backend). Search for `gateway`. Open the slow trace. Follow the spans.

## 25–35 — Identify the bottleneck
Show the long `recommendation-service` / `slow-external-dependency` span.
Explain that “network latency” must be localized, not guessed.

## 35–45 — Correlate and reason
Discuss trace context, logs, metrics, retries/timeouts, DNS/connectivity, external dependencies.

## 45–52 — Remediate live
Change `DELAY_SECONDS` from 3.0 to 0.2, redeploy, rerun the same request, compare traces.

## 52–56 — Optional AI finale
Reuse the strongest part of the previous AWS talk: provide curated telemetry context to an AI assistant and ask for an evidence-backed hypothesis. Keep this vendor-neutral in the narrative.

## 56–60 — Takeaways / Q&A
Close: **“A Running Pod is an answer to one question. Your job as an engineer is to know which question to ask next.”**

## Demo safety
- Start all containers before the session.
- Keep one known-good trace open in a browser tab as fallback.
- Have terminal commands copied in a text file.
- Avoid changing more than one failure variable live.
- The demo is fictional and does not represent any employer or banking architecture.
