import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  static const _baseUrl = 'https://github.com/google-ai-edge/ai-edge-apis/blob/main/local_agents/rag/java/com/google/ai/edge/localagents/rag';

  final List<_ModuleData> _modules = const [
    _ModuleData(
      icon: Icons.psychology,
      title: 'LanguageModel',
      subtitle: 'LLM Interface',
      description:
          'Open-prompt LLM API for local (on-device) and server-based models. The core inference engine for RAG generation.',
      color: Color(0xFFEC4899),
      path: '/models/LanguageModel.java',
      tags: ['LLM', 'Inference', 'On-Device', 'Server'],
    ),
    _ModuleData(
      icon: Icons.scatter_plot,
      title: 'Embedder',
      subtitle: 'Text Embedding Interface',
      description:
          'Converts structured and unstructured text into high-dimensional embedding vectors for semantic similarity search.',
      color: Color(0xFF00D4FF),
      path: '/models/Embedder.java',
      tags: ['Embedding', 'Vectors', 'Semantic'],
    ),
    _ModuleData(
      icon: Icons.storage,
      title: 'VectorStore',
      subtitle: 'Embedding Storage',
      description:
          'Holds embeddings and metadata derived from data chunks. Supports similarity queries and exact match lookups.',
      color: Color(0xFF10B981),
      path: '/memory/VectorStore.java',
      tags: ['Storage', 'Index', 'kNN'],
    ),
    _ModuleData(
      icon: Icons.memory,
      title: 'SemanticMemory',
      subtitle: 'Semantic Retriever',
      description:
          'Retrieves top-k relevant chunks for a given query using semantic similarity. The core retrieval engine in RAG.',
      color: Color(0xFF7C3AED),
      path: '/memory/SemanticMemory.java',
      tags: ['Retrieval', 'Top-K', 'Similarity'],
    ),
    _ModuleData(
      icon: Icons.content_cut,
      title: 'TextChunker',
      subtitle: 'Document Splitter',
      description:
          'Splits user-provided text data into smaller overlapping or fixed-size chunks to facilitate optimal indexing.',
      color: Color(0xFFF59E0B),
      path: '/chunking/TextChunker.java',
      tags: ['Chunking', 'Preprocessing', 'Indexing'],
    ),
    _ModuleData(
      icon: Icons.account_tree,
      title: 'Chain',
      subtitle: 'Pipeline Orchestration',
      description:
          'Combines multiple RAG components into a single pipeline. Use RetrievalAndInferenceChain or RetrievalChain.',
      color: Color(0xFFF97316),
      path: '/chains/Chain.java',
      tags: ['Pipeline', 'Orchestration', 'Chain'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSDKBanner(context),
            const SizedBox(height: 20),
            ..._modules.map((m) => _buildModuleCard(context, m)),
            const SizedBox(height: 20),
            _buildChainsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SDK Modules',
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          'AI Edge RAG SDK · Key Interfaces',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSDKBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl('https://ai.google.dev/edge/mediapipe/solutions/genai/android'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0EA5E9).withOpacity(0.15),
              const Color(0xFF7C3AED).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.android,
                color: Color(0xFF00D4FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Edge RAG SDK',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Fully on-device Android · MediaPipe GenAI',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      color: const Color(0xFF00D4FF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: Color(0xFF6B7280),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, _ModuleData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: data.color.withOpacity(0.25)),
                  ),
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: GoogleFonts.spaceMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        data.subtitle,
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          color: data.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.description,
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          color: const Color(0xFF9CA3AF),
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: data.tags.map((tag) => _buildTag(tag, data.color)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFF1F2937)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _launchUrl('$_baseUrl${data.path}'),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      child: Row(
                        children: [
                          Icon(Icons.code, size: 13, color: data.color.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data.path.split('/').last,
                              style: GoogleFonts.spaceMono(
                                fontSize: 9,
                                color: data.color.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 38, color: const Color(0xFF1F2937)),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '$_baseUrl${data.path}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'URL copied',
                          style: GoogleFonts.spaceMono(fontSize: 11),
                        ),
                        backgroundColor: const Color(0xFF111827),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    child: Icon(
                      Icons.copy,
                      size: 15,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 8,
          color: color.withOpacity(0.8),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildChainsSection(BuildContext context) {
    final chains = [
      _ChainData(
        name: 'RetrievalAndInferenceChain',
        description: 'Full end-to-end RAG pipeline: retrieves relevant chunks from VectorStore and passes them to the LLM for response generation.',
        path: '/chains/RetrievalAndInferenceChain.java',
        color: const Color(0xFF00D4FF),
      ),
      _ChainData(
        name: 'RetrievalChain',
        description: 'Retrieval-only chain: queries VectorStore via SemanticMemory and returns the top-k relevant chunks without LLM generation.',
        path: '/chains/RetrievalChain.java',
        color: const Color(0xFF10B981),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHAINS',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: const Color(0xFF6B7280),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...chains.map(
          (c) => GestureDetector(
            onTap: () => _launchUrl('$_baseUrl${c.path}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.color.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_tree, color: c.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: c.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.description,
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: const Color(0xFF9CA3AF),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, color: const Color(0xFF4B5563), size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ModuleData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final String path;
  final List<String> tags;

  const _ModuleData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.path,
    required this.tags,
  });
}

class _ChainData {
  final String name;
  final String description;
  final String path;
  final Color color;

  const _ChainData({
    required this.name,
    required this.description,
    required this.path,
    required this.color,
  });
}
