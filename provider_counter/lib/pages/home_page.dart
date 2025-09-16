import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/counter_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterModel>(); // ฟังการเปลี่ยนค่า
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Provider'),
        actions: [
          IconButton(
            tooltip: 'รีเซ็ตเป็น 0',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CounterModel>().reset(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ค่าปัจจุบันของตัวนับ', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '${counter.count}',
                key: ValueKey(counter.count),
                style: textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 24),
            // ปุ่มแถวบน: reset / -1 / +1
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.read<CounterModel>().reset(),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('รีเซ็ต'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.read<CounterModel>().decrement(),
                  icon: const Icon(Icons.remove),
                  label: const Text('ลบ 1'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => context.read<CounterModel>().increment(),
                  icon: const Icon(Icons.add),
                  label: const Text('เพิ่ม 1'),
                ),
              ],
            ),
          ],
        ),
      ),
      // FAB หลายปุ่มวางใน Column ตามที่อธิบายในไฟล์
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_inc',
            onPressed: () => context.read<CounterModel>().increment(),
            icon: const Icon(Icons.add),
            label: const Text('เพิ่ม 1'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'fab_dec',
            onPressed: () => context.read<CounterModel>().decrement(),
            icon: const Icon(Icons.remove),
            label: const Text('ลบ 1'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'fab_reset',
            onPressed: () => context.read<CounterModel>().reset(),
            icon: const Icon(Icons.refresh),
            label: const Text('รีเซ็ต'),
          ),
        ],
      ),
    );
  }
}
