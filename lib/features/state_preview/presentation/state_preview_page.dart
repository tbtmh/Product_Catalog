import 'package:flutter/material.dart';

import '../../../core/widgets/common_widgets.dart';

enum _Sim { loading, error, empty }

class StatePreviewPage extends StatefulWidget {
  const StatePreviewPage({super.key});

  @override
  State<StatePreviewPage> createState() => _StatePreviewPageState();
}

class _StatePreviewPageState extends State<StatePreviewPage> {
  _Sim _sim = _Sim.loading;
  int _token = 0;

  static const _info = {
    _Sim.loading: (
      title: 'Loading State',
      when: 'แสดงตอนเปิดแอป หรือเมื่อเปลี่ยนหมวด/คำค้น ระหว่างรอข้อมูลจาก API',
    ),
    _Sim.error: (
      title: 'Error State',
      when: 'แสดงเมื่อโหลดครั้งแรกไม่สำเร็จ เช่น ไม่มีอินเทอร์เน็ต, timeout, '
          'เซิร์ฟเวอร์ผิดพลาด พร้อมปุ่มลองใหม่',
    ),
    _Sim.empty: (
      title: 'Empty State',
      when: 'แสดงเมื่อ API ตอบกลับสำเร็จแต่ไม่มีสินค้า เช่น ค้นหาแล้วไม่พบ',
    ),
  };

  void _select(_Sim s) => setState(() {
        _token++;
        _sim = s;
      });

  Future<void> _simulateRetry() async {
    final token = ++_token;
    setState(() => _sim = _Sim.loading);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted || token != _token) return;
    setState(() => _sim = _Sim.error);
  }

  Future<void> _simulateRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('จำลอง Pull-to-Refresh เสร็จสิ้น')),
      );
  }

  Widget _preview() {
    switch (_sim) {
      case _Sim.loading:
        return const ScrollableCenter(child: LoadingView());
      case _Sim.error:
        return ScrollableCenter(
          child: ErrorView(
            message: 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้',
            onRetry: _simulateRetry,
          ),
        );
      case _Sim.empty:
        return const ScrollableCenter(
          child: EmptyView(
            title: 'ไม่พบสินค้าสำหรับ "xyz"',
            subtitle: 'ดึงลงเพื่อรีเฟรช',
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _info[_sim]!;

    return Scaffold(
      appBar: AppBar(title: const Text('จำลอง State')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            color: theme.colorScheme.onSecondaryContainer),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'หน้านี้เป็นการจำลอง ไม่ได้เรียก API จริง '
                            'เลือกสถานะด้านล่างเพื่อดูหน้าตาที่ผู้ใช้จะเห็น '
                            'และลองดึงลงเพื่อ Pull-to-Refresh ได้',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<_Sim>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _Sim.loading,
                        icon: Icon(Icons.hourglass_empty, size: 18),
                        label: Text('Loading'),
                      ),
                      ButtonSegment(
                        value: _Sim.error,
                        icon: Icon(Icons.wifi_off, size: 18),
                        label: Text('Error'),
                      ),
                      ButtonSegment(
                        value: _Sim.empty,
                        icon: Icon(Icons.inbox_outlined, size: 18),
                        label: Text('Empty'),
                      ),
                    ],
                    selected: {_sim},
                    onSelectionChanged: (s) => _select(s.first),
                  ),
                ),
                const SizedBox(height: 12),
                Text(info.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(info.when, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: RefreshIndicator(
                      onRefresh: _simulateRefresh,
                      child: _preview(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
