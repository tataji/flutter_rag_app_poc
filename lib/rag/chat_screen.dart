import 'package:flutter/material.dart';
import 'package:flutter_rag_app_poc/rag/rag_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    'How do embeddings work?',
    'What are RAG chains?',
    'Explain text chunking',
    'Is this on-device or cloud?',
    'What is SemanticMemory?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RAGProvider>(
      builder: (context, rag, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        final isPipelineReady = rag.currentStep == PipelineStep.done;

        return SafeArea(
          child: Column(
            children: [
              _buildHeader(rag),
              if (!isPipelineReady) _buildNotReadyBanner(),
              Expanded(
                child: rag.messages.isEmpty
                    ? _buildEmptyState(context, rag, isPipelineReady)
                    : _buildMessageList(rag),
              ),
              if (isPipelineReady) _buildSuggestions(context, rag),
              _buildInputBar(context, rag, isPipelineReady),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(RAGProvider rag) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RAG Chat',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  rag.currentStep == PipelineStep.done
                      ? '${rag.totalVectors} vectors · RetrievalAndInferenceChain'
                      : 'Initialize pipeline first',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (rag.currentStep == PipelineStep.done)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotReadyBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Go to Pipeline tab and initialize the RAG pipeline first.',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, RAGProvider rag, bool isReady) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF7C3AED),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isReady ? 'Ask the RAG Pipeline' : 'Pipeline Not Ready',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isReady
                  ? 'Ask anything about the AI Edge RAG SDK. Responses are grounded in the indexed knowledge base using SemanticMemory retrieval.'
                  : 'Initialize the pipeline in the Pipeline tab to start querying with RAG.',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(RAGProvider rag) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: rag.messages.length + (rag.isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == rag.messages.length && rag.isProcessing) {
          return _buildTypingIndicator();
        }
        final msg = rag.messages[index];
        return msg.isUser ? _buildUserBubble(msg) : _buildAIBubble(msg);
      },
    );
  }

  Widget _buildUserBubble(RAGMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF7C3AED)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAIBubble(RAGMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  'LLM · LanguageModel',
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: const Color(0xFFD1D5DB),
                  height: 1.6,
                ),
              ),
            ),
            if (msg.retrievedChunks != null && msg.retrievedChunks!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildRetrievedChunks(msg.retrievedChunks!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRetrievedChunks(List<RAGChunk> chunks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF6B7280), size: 12),
            const SizedBox(width: 4),
            Text(
              'RETRIEVED CONTEXT · SemanticMemory top-${chunks.length}',
              style: GoogleFonts.spaceMono(
                fontSize: 8,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...chunks.map((chunk) => _buildChunkCard(chunk)),
      ],
    );
  }

  Widget _buildChunkCard(RAGChunk chunk) {
    final sim = chunk.similarity;
    final color = sim > 0.8
        ? const Color(0xFF10B981)
        : sim > 0.6
            ? const Color(0xFFF59E0B)
            : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              chunk.text,
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: const Color(0xFF9CA3AF),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                '${(sim * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'sim',
                style: GoogleFonts.spaceMono(
                  fontSize: 7,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: const Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Retrieving & generating...',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, RAGProvider rag) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              if (!rag.isProcessing) {
                rag.sendMessage(_suggestions[i]);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Text(
                _suggestions[i],
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, RAGProvider rag, bool isReady) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isReady
                      ? const Color(0xFF00D4FF).withOpacity(0.2)
                      : const Color(0xFF1F2937),
                ),
              ),
              child: TextField(
                controller: _controller,
                enabled: isReady && !rag.isProcessing,
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: isReady ? 'Ask about AI Edge RAG...' : 'Pipeline not ready...',
                  hintStyle: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: const Color(0xFF4B5563),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (val) {
                  if (isReady && val.trim().isNotEmpty) {
                    rag.sendMessage(val.trim());
                    _controller.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (isReady && !rag.isProcessing && _controller.text.trim().isNotEmpty) {
                rag.sendMessage(_controller.text.trim());
                _controller.clear();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: (isReady && !rag.isProcessing)
                    ? const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                      )
                    : null,
                color: (isReady && !rag.isProcessing) ? null : const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.send,
                color: (isReady && !rag.isProcessing)
                    ? Colors.white
                    : const Color(0xFF4B5563),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
