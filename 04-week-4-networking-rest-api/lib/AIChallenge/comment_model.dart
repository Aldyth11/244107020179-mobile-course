class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // Factory constructor untuk membuat objek Comment dari map JSON.
  // Dilengkapi dengan null safety fallback untuk menghindari error saat data tidak lengkap.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      // Jika field null atau hilang, kita berikan nilai default
      postId: json['postId'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}
