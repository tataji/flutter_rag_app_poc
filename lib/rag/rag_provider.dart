import 'package:flutter/material.dart';
import 'dart:math';

enum PipelineStep { idle, importing, chunking, embedding, indexing, retrieving, generating, done }

class RAGChunk {
  final String id;
  final String text;
  final double similarity;
  final List<double> embedding;

  RAGChunk({
    required this.id,
    required this.text,
    required this.similarity,
    required this.embedding,
  });
}

class RAGDocument {
  final String id;
  final String title;
  final String content;
  final String source;
  int chunkCount;
  bool isIndexed;

  RAGDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.source,
    this.chunkCount = 0,
    this.isIndexed = false,
  });
}

class RAGMessage {
  final String id;
  final String text;
  final bool isUser;
  final List<RAGChunk>? retrievedChunks;
  final DateTime timestamp;

  RAGMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.retrievedChunks,
    required this.timestamp,
  });
}

class RAGProvider extends ChangeNotifier {
  PipelineStep _currentStep = PipelineStep.idle;
  List<RAGDocument> _documents = [];
  List<RAGChunk> _vectorStore = [];
  List<RAGMessage> _messages = [];
  double _progressValue = 0.0;
  String _statusMessage = '';
  bool _isProcessing = false;
  int _totalVectors = 0;

  // Sample documents about AI Edge RAG SDK
  final List<Map<String, String>> _sampleDocs = [
    {
      'title': 'RAG Pipeline Overview',
      'source': 'ai.google.dev/edge',
      'content':
          'The AI Edge RAG SDK provides fundamental components to construct a Retrieval Augmented Generation pipeline. It enables LLMs to access user-provided data including updated, sensitive, or domain-specific information. The pipeline includes data import, splitting and indexing, embedding generation, information retrieval, and text generation with LLM.',
    },
    {
      'title': 'Language Models Module',
      'source': 'github.com/google-ai-edge',
      'content':
          'Language Models in the AI Edge RAG SDK provide LLM models with open-prompt API. Models can be either local (on-device) or server-based. The API is based on the LanguageModel interface. On-device processing ensures complete privacy and offline functionality without any network dependency.',
    },
    {
      'title': 'Text Embedding Models',
      'source': 'github.com/google-ai-edge',
      'content':
          'Text Embedding Models convert structured and unstructured text into embedding vectors for semantic search. The API is based on the Embedder interface. These vectors capture semantic meaning and enable similarity-based retrieval. Each chunk is transformed into a high-dimensional vector in the embedding space.',
    },
    {
      'title': 'Vector Stores & Semantic Memory',
      'source': 'github.com/google-ai-edge',
      'content':
          'Vector Stores hold embeddings and metadata derived from data chunks. They can be queried to get similar chunks or exact matches using the VectorStore interface. Semantic Memory serves as a semantic retriever for retrieving top-k relevant chunks given a query, based on the SemanticMemory interface.',
    },
    {
      'title': 'Text Chunking & Chains',
      'source': 'github.com/google-ai-edge',
      'content':
          'Text Chunking splits user data into smaller pieces to facilitate indexing using the TextChunker interface. Chains combine several RAG components in a single pipeline. The RetrievalAndInferenceChain and RetrievalChain are provided for orchestrating retrieval and query models.',
    },
  ];

  PipelineStep get currentStep => _currentStep;
  List<RAGDocument> get documents => _documents;
  List<RAGChunk> get vectorStore => _vectorStore;
  List<RAGMessage> get messages => _messages;
  double get progressValue => _progressValue;
  String get statusMessage => _statusMessage;
  bool get isProcessing => _isProcessing;
  int get totalVectors => _totalVectors;

  // Simulate importing documents
  Future<void> importDocuments() async {
    _isProcessing = true;
    _currentStep = PipelineStep.importing;
    _statusMessage = 'Importing documents...';
    _progressValue = 0.0;
    notifyListeners();

    for (int i = 0; i < _sampleDocs.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      final doc = _sampleDocs[i];
      _documents.add(
        RAGDocument(
          id: 'doc_$i',
          title: doc['title']!,
          content: doc['content']!,
          source: doc['source']!,
        ),
      );
      _progressValue = (i + 1) / _sampleDocs.length;
      _statusMessage = 'Importing: ${doc['title']}';
      notifyListeners();
    }

    await _chunkDocuments();
  }

  Future<void> _chunkDocuments() async {
    _currentStep = PipelineStep.chunking;
    _progressValue = 0.0;
    _statusMessage = 'Splitting text into chunks...';
    notifyListeners();

    for (int i = 0; i < _documents.length; i++) {
      await Future.delayed(const Duration(milliseconds: 350));
      final words = _documents[i].content.split(' ');
      _documents[i].chunkCount = max(1, (words.length / 15).ceil());
      _progressValue = (i + 1) / _documents.length;
      notifyListeners();
    }

    await _generateEmbeddings();
  }

  Future<void> _generateEmbeddings() async {
    _currentStep = PipelineStep.embedding;
    _progressValue = 0.0;
    _statusMessage = 'Generating embedding vectors...';
    notifyListeners();

    final rng = Random();
    int chunkIdx = 0;
    int totalChunks = _documents.fold(0, (sum, d) => sum + d.chunkCount);

    for (int docIdx = 0; docIdx < _documents.length; docIdx++) {
      final doc = _documents[docIdx];
      final words = doc.content.split(' ');
      final chunkSize = 15;
      for (int ci = 0; ci < doc.chunkCount; ci++) {
        await Future.delayed(const Duration(milliseconds: 200));
        int start = ci * chunkSize;
        int end = min(start + chunkSize, words.length);
        final chunkText = words.sublist(start, end).join(' ');
        final fakeEmbedding = List.generate(8, (_) => rng.nextDouble() * 2 - 1);
        _vectorStore.add(
          RAGChunk(
            id: 'chunk_${docIdx}_$ci',
            text: chunkText,
            similarity: 0.0,
            embedding: fakeEmbedding,
          ),
        );
        chunkIdx++;
        _progressValue = chunkIdx / totalChunks;
        _totalVectors = _vectorStore.length;
        _statusMessage = 'Vectorizing chunk $chunkIdx/$totalChunks';
        notifyListeners();
      }
      _documents[docIdx].isIndexed = true;
    }

    _currentStep = PipelineStep.indexing;
    _statusMessage = 'Indexing vector store...';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    _currentStep = PipelineStep.done;
    _statusMessage = 'Pipeline ready. ${_vectorStore.length} vectors indexed.';
    _isProcessing = false;
    notifyListeners();
  }

  Future<List<RAGChunk>> retrieveChunks(String query) async {
    _currentStep = PipelineStep.retrieving;
    _statusMessage = 'Retrieving relevant chunks...';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate semantic similarity scoring
    final rng = Random(query.hashCode);
    final scored = _vectorStore.map((chunk) {
      final queryWords = query.toLowerCase().split(' ');
      final chunkWords = chunk.text.toLowerCase().split(' ');
      double overlap = queryWords.where((w) => chunkWords.contains(w)).length.toDouble();
      double similarity = 0.4 + (overlap / max(queryWords.length, 1)) * 0.45 + rng.nextDouble() * 0.15;
      return RAGChunk(
        id: chunk.id,
        text: chunk.text,
        similarity: min(similarity, 0.99),
        embedding: chunk.embedding,
      );
    }).toList();

    scored.sort((a, b) => b.similarity.compareTo(a.similarity));
    return scored.take(3).toList();
  }

  Future<void> sendMessage(String query) async {
    if (query.trim().isEmpty || _isProcessing) return;
    _isProcessing = true;

    _messages.add(RAGMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    final chunks = await retrieveChunks(query);

    _currentStep = PipelineStep.generating;
    _statusMessage = 'Generating response with LLM...';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));

    final topChunk = chunks.isNotEmpty ? chunks.first.text : '';
    final response = _generateSimulatedResponse(query, topChunk, chunks);

    _messages.add(RAGMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_resp',
      text: response,
      isUser: false,
      retrievedChunks: chunks,
      timestamp: DateTime.now(),
    ));

    _currentStep = PipelineStep.done;
    _statusMessage = 'Response generated using ${chunks.length} retrieved chunks.';
    _isProcessing = false;
    notifyListeners();
  }

  String _generateSimulatedResponse(String query, String context, List<RAGChunk> chunks) {
    final q = query.toLowerCase();
    if (q.contains('embed') || q.contains('vector')) {
      return 'Based on the indexed knowledge base: Text Embedding Models convert structured and unstructured text into high-dimensional embedding vectors for semantic search. Each text chunk is transformed using the Embedder interface, capturing semantic meaning to enable similarity-based retrieval from the VectorStore.';
    } else if (q.contains('chunk') || q.contains('split')) {
      return 'According to the retrieved context: Text Chunking splits user data into smaller pieces to facilitate indexing, implemented via the TextChunker interface. Smaller chunks improve retrieval precision and ensure the LLM receives the most relevant context window content.';
    } else if (q.contains('chain') || q.contains('pipeline')) {
      return 'From the AI Edge RAG documentation: Chains combine multiple RAG components into a single orchestrated pipeline. The RetrievalAndInferenceChain integrates retrieval and LLM inference, while the RetrievalChain handles only the retrieval step — both based on the Chain interface.';
    } else if (q.contains('android') || q.contains('on-device') || q.contains('offline')) {
      return 'The AI Edge RAG SDK is available for Android and runs completely on-device. This enables private, offline RAG pipelines with no network dependency — ideal for sensitive data scenarios. The SDK integrates with the LLM Inference API for fully local inference.';
    } else {
      return 'Based on ${chunks.length} retrieved context chunks (top similarity: ${(chunks.first.similarity * 100).toStringAsFixed(1)}%): The AI Edge RAG SDK enables on-device Retrieval Augmented Generation on Android, combining Language Models, Text Embedders, Vector Stores, and Semantic Memory into a complete pipeline for context-aware LLM responses.';
    }
  }

  void reset() {
    _currentStep = PipelineStep.idle;
    _documents.clear();
    _vectorStore.clear();
    _messages.clear();
    _progressValue = 0.0;
    _statusMessage = '';
    _isProcessing = false;
    _totalVectors = 0;
    notifyListeners();
  }
}
