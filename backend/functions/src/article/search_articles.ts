import { onCall, CallableRequest, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { getEmbeddingProvider } from '../ai/factory';
import { checkRateLimit } from '../shared/rate_limiter';
import { GEMINI_API_KEY } from '../shared/secrets';

interface SearchRequestData {
  query?: unknown;
  limit?: unknown;
}

interface SearchResult {
  articleId: string;
  distance: number;
}

interface SearchResponse {
  results: SearchResult[];
}

const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 50;
const MAX_QUERY_LEN = 200;

// Cosine distance cutoff. `findNearest` always returns the top-N closest
// vectors regardless of how dissimilar they are — with a small collection,
// every query would otherwise return the same articles. A distance > 0.85
// (cosine angle > ~67°) means the texts are not semantically related and
// should NOT appear in results.
const MAX_RELEVANT_DISTANCE = 0.85;

export async function handleSearchRequest(
  request: CallableRequest<SearchRequestData>,
): Promise<SearchResponse> {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in to search.');
  }

  const uid = request.auth.uid;
  if (!checkRateLimit(uid)) {
    throw new HttpsError('resource-exhausted', 'Too many search queries. Try again in a moment.');
  }

  const { query, limit } = parseAndValidateArgs(request.data);

  const provider = getEmbeddingProvider();
  const queryVector = await provider.embed(query);

  const snapshot = await getFirestore()
    .collection('articles')
    .where('status', '==', 'published')
    .where('isDeleted', '==', false)
    .findNearest({
      vectorField: 'embedding',
      queryVector: FieldValue.vector(queryVector),
      limit,
      distanceMeasure: 'COSINE',
      distanceResultField: '_distance',
    })
    .get();

  const allResults: SearchResult[] = snapshot.docs.map((doc) => ({
    articleId: doc.id,
    distance: doc.get('_distance') as number,
  }));

  const results = allResults.filter((r) => r.distance <= MAX_RELEVANT_DISTANCE);

  logger.info('search completed', {
    uid,
    queryLength: query.length,
    candidateCount: allResults.length,
    resultCount: results.length,
    topDistance: allResults[0]?.distance,
    cutoff: MAX_RELEVANT_DISTANCE,
    provider: provider.modelName,
  });

  return { results };
}

function parseAndValidateArgs(data: SearchRequestData): { query: string; limit: number } {
  const rawQuery = data?.query;
  if (typeof rawQuery !== 'string') {
    throw new HttpsError('invalid-argument', 'query must be a string');
  }
  const query = rawQuery.trim();
  if (query.length < 1 || query.length > MAX_QUERY_LEN) {
    throw new HttpsError('invalid-argument', `query length must be 1-${MAX_QUERY_LEN}`);
  }

  const rawLimit = data?.limit;
  let limit: number = DEFAULT_LIMIT;
  if (rawLimit !== undefined && rawLimit !== null) {
    if (typeof rawLimit !== 'number' || !Number.isInteger(rawLimit)) {
      throw new HttpsError('invalid-argument', 'limit must be an integer');
    }
    limit = rawLimit;
  }
  if (limit < 1 || limit > MAX_LIMIT) {
    throw new HttpsError('invalid-argument', `limit must be 1-${MAX_LIMIT}`);
  }

  return { query, limit };
}

export const searchArticles = onCall(
  {
    region: 'us-central1',
    secrets: [GEMINI_API_KEY],
  },
  handleSearchRequest,
);
