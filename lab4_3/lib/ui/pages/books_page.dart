import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../models/book.dart';
import 'book_detail_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final bookProv = context.watch<BookProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục sách'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Tìm theo tiêu đề…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Book>>(
        stream: bookProv.watchBooks(search: _controller.text.trim()),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snap.data!;
          if (books.isEmpty) return const Center(child: Text('Chưa có sách'));
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.66,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: books.length,
            itemBuilder: (_, i) {
              final b = books[i];
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookDetailPage(book: b)),
                ),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children: [
                      Expanded(
                        child: b.coverUrl != null
                            ? Image.network(
                                b.coverUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : const Icon(Icons.menu_book, size: 80),
                      ),
                      ListTile(
                        title: Text(
                          b.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          b.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          b.available ? Icons.check_circle : Icons.cancel,
                          color: b.available ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
