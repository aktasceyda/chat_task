import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';

class BulletinDetailScreen extends ConsumerWidget {
  final String pathname;

  const BulletinDetailScreen({
    super.key,
    required this.pathname,
  });

  Future<void> _handleLinkTap(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(bulletinDetailProvider(pathname));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF475569)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          asyncValue.when(
            data: (data) => _formatDate(data['created_at'] as String?),
            loading: () => 'Yükleniyor...',
            error: (_, __) => '',
          ),
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Color(0xFF475569)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
        ),
      ),
      body: asyncValue.when(
        data: (data) {
          final rawContent = data['content'] as String? ?? '';
          final title = data['title'] as String? ?? '';
          final coverPhoto = data['cover_photo'] as String?;

          final sections = _parseSections(rawContent, title);
          final sectionKeys = List.generate(sections.length, (_) => GlobalKey());

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatTimeAgo(data['created_at'] as String?),
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text(_formatReadingTime(data['reading_time_seconds'] as int?),
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'İçerik:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(sections.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              final context = sectionKeys[index].currentContext;
                              if (context != null) {
                                Scrollable.ensureVisible(
                                  context,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              '• ${sections[index].heading}',
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),

                      if (coverPhoto != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedNetworkImage(
                              imageUrl: coverPhoto,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      ...List.generate(sections.length, (index) {
                        final section = sections[index];
                        return Column(
                          key: sectionKeys[index],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.heading,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            MarkdownBody(
                              data: section.body,
                              selectable: false,
                              onTapLink: (text, href, title) => _handleLinkTap(href),
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                    fontSize: 16, height: 1.7, color: Color(0xFF334155)),
                                listBullet: const TextStyle(
                                    fontSize: 16, color: Color(0xFF334155)),
                                listIndent: 20,
                                blockSpacing: 16,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      }),

                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uyarı Notu',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1E293B)),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Raporda yer alan bilgiler bilgilendirme amacıyla hazırlanmıştır. Sunulan bilgiler yatırım danışmanlığı kapsamında değildir.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildBottomNavigationBar(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('İçerik yüklenemedi'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(bulletinDetailProvider(pathname)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stripImages(String markdown) {
    return markdown.replaceAll(RegExp(r'!\[.*?\]\(.*?\)\s*'), '');
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  List<_Section> _parseSections(String content, String mainTitle) {
    final cleanedContent = _stripHtml(_stripImages(content));

    final List<_Section> sections = [];
    final lines = cleanedContent.split('\n');

    String currentHeading = mainTitle;
    List<String> currentBodyLines = [];

    for (var line in lines) {
      if (line.startsWith('## ') || line.startsWith('# ')) {
        if (currentBodyLines.isNotEmpty ||
            (currentHeading != mainTitle && currentHeading.isNotEmpty)) {
          final body = currentBodyLines.join('\n').trim();
          if (body.isNotEmpty || currentHeading != mainTitle) {
            sections.add(_Section(heading: currentHeading, body: body));
          }
        }
        currentHeading = line.replaceAll('#', '').trim();
        currentBodyLines = [];
      } else {
        currentBodyLines.add(line);
      }
    }

    if (currentBodyLines.isNotEmpty ||
        (currentHeading != mainTitle && currentHeading.isNotEmpty)) {
      final body = currentBodyLines.join('\n').trim();
      if (body.isNotEmpty || currentHeading != mainTitle) {
        sections.add(_Section(heading: currentHeading, body: body));
      }
    }

    if (sections.isEmpty && mainTitle.isNotEmpty) {
      sections.add(_Section(heading: mainTitle, body: cleanedContent.trim()));
    }

    return sections;
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, 'Ana Sayfa', false),
              _buildNavItem(Icons.grid_view, 'Hizmetler', true),
              _buildNavItem(Icons.description, 'Karne', false),
              _buildNavItem(Icons.campaign, 'Kampanya', false),
              _buildNavItem(Icons.person_outline, 'Profil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final color = isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF94A3B8);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Aralık 2025';
    try {
      DateFormat format = DateFormat("EEE, d MMM y HH:mm:ss 'GMT'", 'en_US');
      DateTime date;
      try {
        date = format.parse(dateStr);
      } catch (_) {
        date = HttpDate.parse(dateStr);
      }
      
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      
      final startDay = monday.day;
      final endDay = sunday.day;
      final monthYear = DateFormat('MMMM yyyy', 'tr_TR').format(sunday);
      
      if (monday.month == sunday.month) {
        return '$startDay - $endDay $monthYear';
      } else {
        final startMonth = DateFormat('MMM', 'tr_TR').format(monday);
        final endMonthYear = DateFormat('MMM yyyy', 'tr_TR').format(sunday);
        return '$startDay $startMonth - $endDay $endMonthYear';
      }
    } catch (e) {
      return 'Aralık 2025';
    }
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      DateFormat format = DateFormat("EEE, d MMM y HH:mm:ss 'GMT'", 'en_US');
      DateTime date = format.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 7) {
        if (difference.inDays > 0) {
          return '${difference.inDays} gün önce';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} saat önce';
        } else if (difference.inMinutes > 0) {
           return '${difference.inMinutes} dakika önce';
        } else {
           return 'Az önce';
        }
      } else {
        return DateFormat('d MMM yyyy', 'tr_TR').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  String _formatReadingTime(int? seconds) {
    if (seconds == null) return '';
    
    else  return '$seconds dakikalık okuma';
    
  
  }
}

class _Section {
  final String heading;
  final String body;

  _Section({required this.heading, required this.body});
}
