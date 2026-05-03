import { GoogleGenerativeAI } from '@google/generative-ai';
import { EmbeddingProvider } from './embedding_provider';

const MODEL_NAME = 'gemini-embedding-001';
const DIMENSIONS = 768;

export class GeminiEmbeddingProvider implements EmbeddingProvider {
  readonly dimensions = DIMENSIONS;
  readonly modelName = MODEL_NAME;

  private readonly client: GoogleGenerativeAI;

  constructor(apiKey: string) {
    this.client = new GoogleGenerativeAI(apiKey);
  }

  async embed(text: string): Promise<number[]> {
    const model = this.client.getGenerativeModel({ model: MODEL_NAME });
    // gemini-embedding-001 defaults to 3072 dims; we pin 768 to match the
    // Firestore vector index dimension declared at deploy time. The
    // `outputDimensionality` field is accepted by the Gemini REST API but
    // not yet present in the legacy `@google/generative-ai` SDK types — the
    // SDK JSON-stringifies the request object verbatim, so the cast is safe.
    const result = await model.embedContent({
      content: { role: 'user', parts: [{ text }] },
      outputDimensionality: DIMENSIONS,
    } as Parameters<typeof model.embedContent>[0]);
    const values = result.embedding?.values;
    if (!values) {
      throw new Error('Gemini embed returned no values');
    }
    return values;
  }

  async embedBatch(texts: string[]): Promise<number[][]> {
    const model = this.client.getGenerativeModel({ model: MODEL_NAME });
    const result = await model.batchEmbedContents({
      requests: texts.map((t) => ({
        content: { role: 'user', parts: [{ text: t }] },
        outputDimensionality: DIMENSIONS,
      })) as Parameters<typeof model.batchEmbedContents>[0]['requests'],
    });
    return result.embeddings.map((e) => {
      const v = e.values;
      if (!v) throw new Error('Gemini batch embed returned no values for an item');
      return v;
    });
  }
}
