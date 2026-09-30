
import os, time
from flask import Flask, jsonify
from otel import setup_otel
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
REQUESTS = Counter("demo_http_requests_total", "HTTP requests", ["service", "method", "path", "status"])
LATENCY = Histogram("demo_http_request_duration_seconds", "HTTP request duration", ["service", "method", "path"])
SERVICE_NAME = "recommendation-service"

@app.before_request
def _metrics_start():
    from flask import g
    g.metrics_started = time.time()

@app.after_request
def _metrics_end(response):
    from flask import request, g
    path = request.url_rule.rule if request.url_rule else request.path
    if path != "/metrics":
        REQUESTS.labels(SERVICE_NAME, request.method, path, str(response.status_code)).inc()
        LATENCY.labels(SERVICE_NAME, request.method, path).observe(time.time() - getattr(g, "metrics_started", time.time()))
    return response

@app.get("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

tracer = setup_otel(app, "recommendation-service")
DELAY=float(os.getenv("DELAY_SECONDS","3.0"))

@app.get("/health")
def health(): return {"status":"ok"}

@app.get("/recommend")
def recommend():
    with tracer.start_as_current_span("slow-external-dependency") as span:
        span.set_attribute("demo.delay_seconds", DELAY)
        span.set_attribute("dependency.type", "simulated-network-call")
        time.sleep(DELAY)
    return jsonify({"item":"experience-plus","delay_seconds":DELAY})
