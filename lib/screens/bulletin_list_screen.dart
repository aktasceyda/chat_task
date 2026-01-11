import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/bulletin_post.dart';
import 'bulletin_detail_screen.dart';

class BulletinListScreen extends ConsumerStatefulWidget {
  const BulletinListScreen({super.key});

  @override
  ConsumerState<BulletinListScreen> createState() => _BulletinListScreenState();
}

class _BulletinListScreenState extends ConsumerState<BulletinListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(bulletinListProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulletinListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF475569)),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'Haftalık Bültenler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await ref.read(bulletinListProvider.notifier).refresh();
            },
            child: _buildBody(state),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody(BulletinListState state) {
    if (state.posts.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.posts.isEmpty && state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(bulletinListProvider.notifier).refresh();
              },
              child: const Text('Tekrar Dene'),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: state.posts.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.posts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final post = state.posts[index];
        return _buildBulletinCard(context, post);
      },
    );
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
    final color =
        isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF94A3B8);
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

  Widget _buildBulletinCard(BuildContext context, BulletinPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BulletinDetailScreen(pathname: post.pathname),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(post.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.subtitle ?? post.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('|',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFFCBD5E1))),
                      ),
                      Text(
                        _formatReadingTime(post.readingTimeSeconds),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (post.coverPhoto != null) ...[
              const SizedBox(width: 16),
              SizedBox(
                width: 96,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: post.coverPhoto!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey.shade100),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Aralık 2025';
    try {
      // Http parse
      DateFormat format = DateFormat("EEE, d MMM y HH:mm:ss 'GMT'", 'en_US');
      DateTime date;
      try {
        date = format.parse(dateStr);
      } catch (_) {
        date = HttpDate.parse(dateStr);
      }
      
      // Calculate start (Monday) and end (Sunday) of the week
      // date.weekday: 1=Mon, 7=Sun
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      
      // Format: 22 - 28 Aralık 2025
      // If months are different: 29 Eyl - 5 Eki 2025 (Optional, but user example shows simpe logic)
      
      final startDay = monday.day;
      final endDay = sunday.day;
      final monthYear = DateFormat('MMMM yyyy', 'tr_TR').format(sunday);
      
      // Check if same month
      if (monday.month == sunday.month) {
        return '$startDay - $endDay $monthYear';
      } else {
        // Different months: 29 Ara - 4 Oca 2026
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
      // "Tue, 30 Dec 2025 22:33:16 GMT" formatı genellikle HttpDate ile parse edilebilir
      // Ancak flutter'da HttpDate dart:io içindedir, web uyumluluğu için
      // intl DateFormat kullanmak daha güvenlidir, fakat bu spesifik format standarttır.
      // Basitçe DateFormat çıkartmayı deneyelim: E, d MMM y HH:mm:ss 'GMT'
      // Yine de en garantisi DateFormat kütüphanesini kullanmaktır.
      
      // Gelen format: Tue, 30 Dec 2025 22:33:16 GMT
      // intl ile parse etmek için:
      DateFormat format = DateFormat("EEE, d MMM y HH:mm:ss 'GMT'", 'en_US');
      DateTime date = format.parse(dateStr);
      
      // Şu anki zamanla fark
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
        // 7 günden fazlaysa -> 29 Ara 2025
        return DateFormat('d MMM yyyy', 'tr_TR').format(date);
      }
    } catch (e) {
      print('Date parse error: $e');
      return '';
    }
  }

  String _formatReadingTime(int? seconds) {
    if (seconds == null) return '';
  
    else  return '$seconds dakikalık okuma';
    
  }
}
