import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/loan_provider.dart';
import '../../providers/auth_provider.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;
  const BookDetailPage({super.key, required this.book});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final loans = context.read<LoanProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (book.coverUrl != null)
            Image.network(book.coverUrl!, height: 260, fit: BoxFit.cover),
          const SizedBox(height: 16),
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          Text('Tác giả: ${book.author}'),
          if (book.category != null) Text('Thể loại: ${book.category}'),
          const SizedBox(height: 8),
          Text(book.description ?? 'Chưa có mô tả'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: !book.available || user == null
                ? null
                : () async {
                    await loans.borrow(bookId: book.id, userId: user.uid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã mượn sách')),
                      );
                      Navigator.pop(context);
                    }
                  },
            icon: const Icon(Icons.shopping_bag),
            label: Text(book.available ? 'Mượn sách' : 'Đã hết'),
          ),
        ],
      ),
    );
  }
}
