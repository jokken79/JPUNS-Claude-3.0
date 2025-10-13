# Validation Checklist for main.py Fixes

Use this checklist to validate that all fixes are working correctly.

## Pre-Deployment Validation

### 1. Static Code Analysis
- [ ] Run Python syntax check: `python -m py_compile app/main.py`
- [ ] No import errors: `python -c "from app.main import app"`
- [ ] Verify middleware order is correct (ExceptionHandler → Logging → Security → CORS → TrustedHost)

### 2. Unit Tests
```bash
cd /home/runner/work/JPUNS-Claude-3.0/JPUNS-Claude-3.0/backend
pytest tests/api/test_main.py -v
pytest tests/api/test_health.py -v
```

**Expected Results:**
- [ ] All tests in test_main.py pass (7 tests)
- [ ] All tests in test_health.py pass (2 tests)
- [ ] No test failures or errors

### 3. Application Startup
```bash
# Start the application
docker-compose up backend

# Or manually
cd backend
uvicorn app.main:app --reload
```

**Check Logs for:**
- [ ] "Starting application" with app_name, version, environment, debug
- [ ] "Required directories created/verified"
- [ ] "Mounted static files from /app/uploads"
- [ ] "Database tables initialized successfully"
- [ ] "Application configuration" with cors_origins, upload_dir, ocr_enabled
- [ ] "All API routers registered successfully"

**No errors should appear for:**
- [ ] Directory creation
- [ ] Static files mounting
- [ ] Database initialization
- [ ] Router registration

### 4. Root Endpoint Test

```bash
curl http://localhost:8000/
```

**Expected Response:**
```json
{
  "app": "UNS-ClaudeJP",
  "version": "2.0",
  "company": "UNS-Kikaku",
  "website": "https://uns-kikaku.com",
  "status": "running",
  "timestamp": "2025-10-13T15:00:00.000000"
}
```

**Validation:**
- [ ] Status code is 200
- [ ] All fields present
- [ ] status is "running"
- [ ] Timestamp is current

### 5. Health Endpoint Test

```bash
curl http://localhost:8000/api/health
```

**Expected Response (DB Connected):**
```json
{
  "status": "healthy",
  "timestamp": "2025-10-13T15:00:00.000000",
  "version": "2.0",
  "environment": "development",
  "database": "connected"
}
```

**Expected Response (DB Disconnected):**
```json
{
  "status": "degraded",
  "timestamp": "2025-10-13T15:00:00.000000",
  "version": "2.0",
  "environment": "development",
  "database": "disconnected"
}
```

**Validation:**
- [ ] Status code is 200 (even if DB is down)
- [ ] All 5 fields present (status, timestamp, version, environment, database)
- [ ] status is "healthy" or "degraded"
- [ ] database is "connected", "disconnected", or "error"
- [ ] version matches APP_VERSION setting
- [ ] environment matches ENVIRONMENT setting

### 6. Security Headers Test

```bash
curl -I http://localhost:8000/
```

**Expected Headers:**
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `X-Frame-Options: DENY`
- [ ] `X-XSS-Protection: 1; mode=block`
- [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] `X-Process-Time: <float>` (added by LoggingMiddleware)

### 7. CORS Test

```bash
curl -X OPTIONS http://localhost:8000/api/health \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -v
```

**Validation:**
- [ ] Response includes `Access-Control-Allow-Origin` header
- [ ] CORS allows configured origins
- [ ] Pre-flight requests handled correctly

### 8. Error Handling Test

**Test 404 Error:**
```bash
curl http://localhost:8000/nonexistent
```

**Expected Response:**
```json
{
  "detail": "Not found",
  "path": "http://localhost:8000/nonexistent"
}
```

**Validation:**
- [ ] Status code is 404
- [ ] Response includes detail and path

### 9. API Router Test

Test that all routers are loaded:

```bash
# Should list all API routes
curl http://localhost:8000/api/docs
```

**Validation:**
- [ ] Swagger UI loads successfully
- [ ] All 13 router tags present:
  - [ ] Authentication
  - [ ] Candidates
  - [ ] Azure OCR
  - [ ] Employees
  - [ ] Factories
  - [ ] Timer Cards
  - [ ] Salary
  - [ ] Requests
  - [ ] Dashboard
  - [ ] Import/Export
  - [ ] Reports
  - [ ] Notifications
  - [ ] Monitoring

### 10. Static Files Test

```bash
# Upload a test file first via API or manually create one
echo "test" > backend/uploads/test.txt

# Then access it
curl http://localhost:8000/uploads/test.txt
```

**Validation:**
- [ ] Static files are accessible via /uploads route
- [ ] Returns correct content

### 11. Middleware Order Validation

The middleware order should ensure:
- [ ] Exceptions from any middleware are caught by ExceptionHandlerMiddleware
- [ ] All requests are logged by LoggingMiddleware
- [ ] Security headers are added by SecurityMiddleware
- [ ] CORS is handled correctly
- [ ] Host validation works in production

**Test by triggering an error:**
```bash
# This should be logged and return a proper error response
curl http://localhost:8000/api/candidates/999999
```

Check logs for:
- [ ] Request is logged with structured data
- [ ] Error is caught and logged
- [ ] Response includes proper error format

---

## Production-Specific Validation

### 12. Production Configuration

When `DEBUG=false`:

**Validation:**
- [ ] TrustedHostMiddleware uses specific hosts: `["uns-kikaku.com", "*.uns-kikaku.com", "localhost"]`
- [ ] Database initialization failure causes app to fail fast (doesn't start)
- [ ] Error messages don't expose internal details

**Test Fail-Fast:**
```bash
# With invalid database configuration and DEBUG=false
DEBUG=false DATABASE_URL="postgresql://invalid:invalid@invalid:5432/invalid" uvicorn app.main:app
```

Expected:
- [ ] Application fails to start
- [ ] Critical log message: "Cannot start application without database"
- [ ] Exception is raised

### 13. Load Balancer Integration

If using a load balancer:

**Validation:**
- [ ] Configure health check to use `/api/health`
- [ ] Health check interval is appropriate (e.g., 30s)
- [ ] Load balancer removes instances with "degraded" status
- [ ] Load balancer re-adds instances when status becomes "healthy"

### 14. Monitoring Integration

**Validation:**
- [ ] Monitor health endpoint for status changes
- [ ] Alert when status becomes "degraded"
- [ ] Track database connectivity over time
- [ ] Monitor application version from health endpoint

---

## Performance Validation

### 15. Response Time Test

```bash
# Use Apache Bench or similar tool
ab -n 1000 -c 10 http://localhost:8000/

ab -n 1000 -c 10 http://localhost:8000/api/health
```

**Validation:**
- [ ] Average response time is acceptable
- [ ] No significant degradation compared to previous version
- [ ] Health check with DB query completes quickly (<100ms typical)

### 16. Memory Usage Test

```bash
# Monitor memory usage during operation
docker stats uns-claudejp-backend
```

**Validation:**
- [ ] Memory usage is stable
- [ ] No memory leaks during extended operation

---

## Rollback Validation

### 17. Rollback Test

If rollback is needed:

```bash
git checkout <previous-commit>
docker-compose restart backend
```

**Validation:**
- [ ] Application starts correctly
- [ ] All routes work
- [ ] Tests pass

---

## Documentation Validation

### 18. Documentation Review

**Validation:**
- [ ] MAIN_PY_FIXES.md accurately describes all changes
- [ ] CHANGES_SUMMARY.md provides clear before/after comparisons
- [ ] VALIDATION_CHECKLIST.md (this file) is comprehensive
- [ ] Code comments are clear and helpful

---

## Final Sign-Off

**Tested By:** _________________

**Date:** _________________

**Environment:** Development / Staging / Production

**Test Results:**
- [ ] All validation steps completed
- [ ] No critical issues found
- [ ] Application ready for deployment

**Notes:**
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________

**Approved for deployment:** Yes / No

**Signature:** _________________
