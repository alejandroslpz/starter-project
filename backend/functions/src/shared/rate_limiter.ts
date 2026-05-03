export const RATE_LIMIT_MAX = 5;
export const RATE_LIMIT_WINDOW_MS = 10000;

const _hits = new Map<string, number[]>();

// In-memory, per-function-instance. Limits do not survive instance churn or
// scale across multiple instances. For production-grade per-user throttling,
// replace with a Firestore counter or Cloud Memorystore.
export function checkRateLimit(uid: string): boolean {
  const now = Date.now();
  const cutoff = now - RATE_LIMIT_WINDOW_MS;
  const recent = (_hits.get(uid) ?? []).filter((t) => t > cutoff);
  if (recent.length >= RATE_LIMIT_MAX) {
    _hits.set(uid, recent);
    return false;
  }
  recent.push(now);
  _hits.set(uid, recent);
  return true;
}

export function _resetRateLimiterForTests(): void {
  _hits.clear();
}
