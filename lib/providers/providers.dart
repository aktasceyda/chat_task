import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bulletin_service.dart';
import '../models/bulletin_post.dart';
import '../models/pagination_meta.dart';

// Service Provider
final bulletinServiceProvider = Provider<BulletinService>((ref) {
  return BulletinService();
});

// State for the list
class BulletinListState {
  final List<BulletinPost> posts;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  BulletinListState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  BulletinListState copyWith({
    List<BulletinPost>? posts,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    Object? error = _noError,
  }) {
    return BulletinListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: identical(error, _noError) ? this.error : error as String?,
    );
  }
}

const Object _noError = Object();

// StateNotifier for Infinite Scroll
class BulletinListNotifier extends StateNotifier<BulletinListState> {
  final BulletinService _service;

  BulletinListNotifier(this._service) : super(BulletinListState()) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, error: null, currentPage: 1, posts: [], hasMore: true);
    try {
      final result = await _service.fetchBulletins(1);
      final posts = List<BulletinPost>.from(result['posts'] as List);
      final meta = result['meta'] as PaginationMeta;
      
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMore: meta.currentPage < meta.totalPages,
        currentPage: meta.currentPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _service.fetchBulletins(nextPage);
      final newPosts = List<BulletinPost>.from(result['posts'] as List);
      final meta = result['meta'] as PaginationMeta;

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoading: false,
        hasMore: meta.currentPage < meta.totalPages,
        currentPage: meta.currentPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchFirstPage();
  }
}

final bulletinListProvider = StateNotifierProvider<BulletinListNotifier, BulletinListState>((ref) {
  final service = ref.watch(bulletinServiceProvider);
  return BulletinListNotifier(service);
});

// Detail Provider
final bulletinDetailProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, pathname) async {
  final service = ref.watch(bulletinServiceProvider);
  return service.fetchBulletinDetail(pathname);
});