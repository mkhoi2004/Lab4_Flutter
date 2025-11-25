import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/loan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/loan.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Hãy đăng nhập để xem lịch sử mượn')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử Mượn/Trả')),
      body: StreamBuilder<List<Loan>>(
        stream: context.read<LoanProvider>().watchMyLoans(uid),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có giao dịch nào.'));
          }

          // ✅ Có index rõ ràng
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final loan = items[index];

              final borrowedAt = _fmt(loan.borrowedAt);
              final returnedAt = loan.returnedAt != null
                  ? _fmt(loan.returnedAt!)
                  : null;

              return ListTile(
                leading: Icon(
                  loan.returnedAt == null
                      ? Icons.book_outlined
                      : Icons.bookmark_added,
                  color: loan.returnedAt == null ? Colors.orange : Colors.green,
                ),
                title: Text('Mã sách: ${loan.bookId}'),
                subtitle: Text(
                  returnedAt == null
                      ? 'Mượn lúc: $borrowedAt'
                      : 'Mượn: $borrowedAt\nTrả: $returnedAt',
                ),
                trailing: loan.returnedAt == null
                    ? TextButton.icon(
                        icon: const Icon(Icons.check, color: Colors.green),
                        label: const Text('Trả sách'),
                        onPressed: () async {
                          await context.read<LoanProvider>().returnBook(loan);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã trả sách.')),
                            );
                          }
                        },
                      )
                    : const Text(
                        'Đã trả',
                        style: TextStyle(color: Colors.grey),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
