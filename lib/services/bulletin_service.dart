import 'package:dio/dio.dart';
import '../models/bulletin_post.dart';
import '../models/pagination_meta.dart';

class BulletinService {
  final Dio _dio;
  static const String _baseUrl = 'https://api2.teklifimgelsin.com/api';

  BulletinService([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  Future<Map<String, dynamic>> fetchBulletins(int page) async {
    try {
      print('Fetching bulletins for page: $page');
      final response = await _dio.get(
        '/blog/blogs',
        queryParameters: {
          'type': 'bulletin',
          'page': page,
          'per_page': 10,
        },
      );

      final data = response.data;
      print('API Response structure keys: ${data.keys}');

      if (data['blogs'] == null) {
        print('Error: blogs key is missing in response');
      }

      final List<dynamic> blogsJson = data['blogs'];
      final Map<String, dynamic> metaJson = data['_meta'];

      print('Blogs count: ${blogsJson.length}');
      print('Meta: $metaJson');

      final posts = blogsJson.map((json) => BulletinPost.fromJson(json)).toList();
      final meta = PaginationMeta.fromJson(metaJson);

      return {
        'posts': posts,
        'meta': meta,
      };
    } catch (e, stack) {
      print('Error fetching bulletins: $e');
      print('Stack trace: $stack');
      throw Exception('Failed to load bulletins: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBulletinDetail(String pathname) async {
    try {
      print('Fetching detail for: $pathname');
      final response = await _dio.get(
        '/getBlogPost',
        queryParameters: {
          'pathname': pathname,
        },
      );

      final data = response.data;
      print('Detail Response keys: ${data.keys}');
      return data;
    } catch (e, stack) {
      print('Error fetching detail: $e');
      print('Stack trace: $stack');
      throw Exception('Failed to load bulletin detail: $e');
    }
  }
}
