/// The contract every embedding backend must satisfy. Business logic depends
/// on this interface only — Gemini, OpenAI, Voyage, Anthropic are all
/// swappable behind it. The factory in ./factory.ts is the single source of
/// provider selection.
export interface EmbeddingProvider {
  readonly dimensions: number;
  readonly modelName: string;
  embed(text: string): Promise<number[]>;
  embedBatch(texts: string[]): Promise<number[][]>;
}
