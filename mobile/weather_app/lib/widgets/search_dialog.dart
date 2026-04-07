import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _recentCities = ['北京', '上海', '广州', '深圳', '杭州'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('搜索城市'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索输入框
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '请输入城市名称',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _controller.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (value) => _searchWeather(value),
          ),
          
          const SizedBox(height: 16),
          
          // 最近搜索
          if (_recentCities.isNotEmpty) ...[
            const Text(
              '最近搜索:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentCities.map((city) {
                return ActionChip(
                  label: Text(city),
                  onPressed: () => _searchWeather(city),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => _searchWeather(_controller.text),
          child: const Text('搜索'),
        ),
      ],
    );
  }

  // 搜索天气
  void _searchWeather(String city) {
    if (city.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入城市名称')),
      );
      return;
    }

    Navigator.pop(context);
    
    // 显示加载提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text('正在查询 $city 的天气...'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // 查询天气
    context.read<WeatherProvider>().fetchWeather(city.trim());
  }
}
