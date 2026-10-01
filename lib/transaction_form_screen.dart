import 'package:flutter/material.dart';

class TransactionFormScreen extends StatefulWidget {
  // Nếu truyền sẵn dữ liệu -> màn hình "Sửa giao dịch"
  // Nếu không truyền gì -> màn hình "Thêm giao dịch"
  final String? initialAmount;
  final String? initialNote;
  final DateTime? initialDate;

  const TransactionFormScreen({
    super.key,
    this.initialAmount,
    this.initialNote,
    this.initialDate,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  bool isExpense = true; // true = Chi tiêu, false = Thu nhập
  String selectedCategory = 'Ăn uống';
  late TextEditingController amountController;
  late TextEditingController noteController;
  late DateTime selectedDate;

  final List<String> categories = ['Ăn uống', 'Di chuyển', 'Mua sắm', 'Hóa đơn', 'Khác'];

  bool get isEditMode => widget.initialAmount != null;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.initialAmount ?? '');
    noteController = TextEditingController(text: widget.initialNote ?? '');
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Chi tiêu / Thu nhập
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isExpense = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isExpense ? Colors.redAccent : Colors.grey[200],
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      ),
                      child: Text(
                        'Chi tiêu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isExpense ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isExpense = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isExpense ? Colors.green : Colors.grey[200],
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                      child: Text(
                        'Thu nhập',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !isExpense ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Danh mục
            const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedCategory = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Số tiền
            const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                suffixText: 'đ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // Ngày giao dịch
            const Text('Ngày giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(_formatDate(selectedDate)),
              ),
            ),
            const SizedBox(height: 20),

            // Ghi chú
            const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú (tùy chọn)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: xử lý lưu giao dịch (sẽ làm ở buổi 5-6 khi có database)
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Lưu', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}