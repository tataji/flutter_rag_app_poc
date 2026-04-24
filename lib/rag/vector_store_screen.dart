import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/rag_provider.dart';

class VectorStoreScreen extends StatefulWidget {
  const VectorStoreScreen({super.key});

  @override
  State<VectorStoreScreen> createState() => _VectorStoreScreenState();
}

class _VectorStoreScreenState extends State<VectorStoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int? _selectedChunkIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RAGProvider>(
      builder: (context, rag, _) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(rag),
              Expanded(
                child: rag.vectorStore.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                        child: Column(
                          children: [
                            _buildVectorVisualizer(rag),
                            const SizedBox(height: 20),
                            _buildVectorList(rag),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(RAGProvider rag) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vector Store',
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            'VectorStore.java · Embedding Space Visualization',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: const Color(0xFF6B7280),
            ),
          ),
          if (rag.totalVectors > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _metricTile('${rag.totalVectors}', 'VECTORS', const Color(0xFF00D4FF)),
                const SizedBox(width: 10),
                _metricTile('${rag.documents.length}', 'DOCS', const Color(0xFF7C3AED)),
                const SizedBox(width: 10),
                _metricTile('8D', 'DIMS', const Color(0xFF10B981)),
                const SizedBox(width: 10),
                _metricTile('cosine', 'METRIC', const Color(0xFFF59E0B)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricTile(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 7,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.2),
              ),
            ),
            child: const Icon(Icons.storage, color: Color(0xFF00D4FF), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Vector Store Empty',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Initialize the pipeline to populate\nthe vector store with embeddings.',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: const Color(0xFF6B7280),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVectorVisualizer(RAGProvider rag) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomPaint(
              painter: _VectorSpacePainter(
                chunks: rag.vectorStore,
                time: _animController.value,
                selectedIndex: _selectedChunkIndex,
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVectorList(RAGProvider rag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STORED EMBEDDINGS',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: const Color(0xFF6B7280),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...rag.vectorStore.asMap().entries.map((e) => _buildVectorRow(e.key, e.value)),
      ],
    );
  }

  Widget _buildVectorRow(int index, RAGChunk chunk) {
    final docColors = [
      const Color(0xFF00D4FF),
      const Color(0xFF7C3AED),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    final docIndex = int.tryParse(chunk.id.split('_')[1]) ?? 0;
    final color = docColors[docIndex % docColors.length];
    final isSelected = _selectedChunkIndex == index;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedChunkIndex = isSelected ? null : index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : const Color(0xFF1F2937),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  chunk.id,
                  style: GoogleFonts.spaceMono(
                    fontSize: 9,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'dim: ${chunk.embedding.length}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 8,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              chunk.text,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: const Color(0xFF9CA3AF),
                height: 1.4,
              ),
              maxLines: isSelected ? 5 : 2,
              overflow: isSelected ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              _buildEmbeddingBars(chunk.embedding, color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddingBars(List<double> embedding, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMBEDDING VECTOR',
          style: GoogleFonts.spaceMono(
            fontSize: 8,
            color: const Color(0xFF6B7280),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: embedding.asMap().entries.map((e) {
            final val = e.value;
            final normalized = (val + 1) / 2;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 40 * normalized,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      val.toStringAsFixed(1),
                      style: GoogleFonts.spaceMono(
                        fontSize: 6,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _VectorSpacePainter extends CustomPainter {
  final List<RAGChunk> chunks;
  final double time;
  final int? selectedIndex;

  _VectorSpacePainter({
    required this.chunks,
    required this.time,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final docColors = [
      const Color(0xFF00D4FF),
      const Color(0xFF7C3AED),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];

    // Draw connection lines
    if (chunks.length > 1) {
      for (int i = 0; i < min(chunks.length, 30); i++) {
        for (int j = i + 1; j < min(chunks.length, 30); j++) {
          final doc1 = int.tryParse(chunks[i].id.split('_')[1]) ?? 0;
          final doc2 = int.tryParse(chunks[j].id.split('_')[1]) ?? 0;
          if (doc1 == doc2) {
            final rngI = Random(i * 1000);
            final rngJ = Random(j * 1000);
            final x1 = 20 + rngI.nextDouble() * (size.width - 40);
            final y1 = 20 + rngI.nextDouble() * (size.height - 40);
            final x2 = 20 + rngJ.nextDouble() * (size.width - 40);
            final y2 = 20 + rngJ.nextDouble() * (size.height - 40);
            final linePaint = Paint()
              ..color = docColors[doc1 % docColors.length].withOpacity(0.08)
              ..strokeWidth = 0.5;
            canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
          }
        }
      }
    }

    // Draw dots
    for (int i = 0; i < chunks.length; i++) {
      final chunkRng = Random(i * 9999);
      final docIndex = int.tryParse(chunks[i].id.split('_')[1]) ?? 0;
      final color = docColors[docIndex % docColors.length];

      double x = 20 + chunkRng.nextDouble() * (size.width - 40);
      double y = 20 + chunkRng.nextDouble() * (size.height - 40);

      // Subtle animation
      x += sin(time * 2 * pi + i) * 3;
      y += cos(time * 2 * pi + i * 0.7) * 2;

      final isSelected = selectedIndex == i;
      final radius = isSelected ? 8.0 : 4.0;

      if (isSelected) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(Offset(x, y), 15, glowPaint);
      }

      final dotPaint = Paint()
        ..color = isSelected ? color : color.withOpacity(0.7);
      canvas.drawCircle(Offset(x, y), radius, dotPaint);

      final borderPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(x, y), radius + 2, borderPaint);
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Embedding Space (2D Projection) · ${chunks.length} vectors',
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 9,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(12, size.height - 20));
  }

  @override
  bool shouldRepaint(_VectorSpacePainter old) =>
      old.time != time || old.selectedIndex != selectedIndex;
}
