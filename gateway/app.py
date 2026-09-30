
import os, time, requests
from flask import Flask, jsonify, render_template_string
from otel import setup_otel
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
REQUESTS = Counter("demo_http_requests_total", "HTTP requests", ["service", "method", "path", "status"])
LATENCY = Histogram("demo_http_request_duration_seconds", "HTTP request duration", ["service", "method", "path"])
SERVICE_NAME = "gateway"

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

tracer = setup_otel(app, "gateway")
ORDER_URL = os.getenv("ORDER_URL", "http://order-service:8081/order")

PAGE = """<!doctype html><html><head><title>JourneyOne</title>
<style>body{font-family:Arial;max-width:760px;margin:70px auto;padding:20px}button{font-size:20px;padding:14px 22px}
#out{white-space:pre-wrap;background:#f4f4f4;padding:18px;margin-top:20px}</style></head>
<body><h1>JourneyOne</h1><p>All services may be healthy — but how long does the user wait?</p>
<button onclick="go()">Place Demo Order</button><div id="out">Ready.</div>
<script>async function go(){const o=document.getElementById('out');o.textContent='Processing...';
const t=performance.now(); const r=await fetch('/api/order'); const j=await r.json();
o.textContent=JSON.stringify(j,null,2)+'\\nBrowser elapsed: '+((performance.now()-t)/1000).toFixed(2)+'s';}</script></body></html>"""

@app.get("/")
def home(): return render_template_string(PAGE)

@app.get("/health")
def health(): return {"status":"ok"}

@app.get("/api/order")
def order():
    start=time.time()
    with tracer.start_as_current_span("user-order-journey"):
        r=requests.get(ORDER_URL, timeout=15)
        payload=r.json()
    return jsonify({"status":"confirmed","backend":payload,"elapsed_seconds":round(time.time()-start,3)})
