
import os, time, requests
from flask import Flask, jsonify
from otel import setup_otel
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
REQUESTS = Counter("demo_http_requests_total", "HTTP requests", ["service", "method", "path", "status"])
LATENCY = Histogram("demo_http_request_duration_seconds", "HTTP request duration", ["service", "method", "path"])
SERVICE_NAME = "order-service"

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

tracer = setup_otel(app, "order-service")
REC_URL = os.getenv("RECOMMENDATION_URL", "http://recommendation-service:8082/recommend")

@app.get("/health")
def health(): return {"status":"ok"}

@app.get("/order")
def order():
    with tracer.start_as_current_span("validate-order"):
        time.sleep(0.08)
    with tracer.start_as_current_span("call-recommendation"):
        rec=requests.get(REC_URL, timeout=12).json()
    with tracer.start_as_current_span("confirm-order"):
        time.sleep(0.05)
    return jsonify({"order_id":"DEMO-42","recommendation":rec,"result":"ok"})
