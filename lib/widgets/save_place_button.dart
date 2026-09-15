import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../services/saved_places_service.dart';

class SavePlaceButton extends StatefulWidget {
  final HeritageResult result;
  final String imagePath;

  const SavePlaceButton({
    super.key,
    required this.result,
    required this.imagePath,
  });

  @override
  State<SavePlaceButton> createState() => _SavePlaceButtonState();
}

class _SavePlaceButtonState extends State<SavePlaceButton> {
  bool _isSaved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final saved = await SavedPlacesService.isSaved(widget.result);

    if (!mounted) return;

    setState(() {
      _isSaved = saved;
      _isLoading = false;
    });
  }

  Future<void> _toggle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final saved = await SavedPlacesService.toggleSave(
        result: widget.result,
        imagePath: widget.imagePath,
      );

      if (!mounted) return;

      setState(() {
        _isSaved = saved;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? '❤️ Đã lưu ${widget.result.name}'
                : 'Đã bỏ khỏi Saved Places',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể lưu địa danh: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }

    return IconButton(
      tooltip: _isSaved ? 'Bỏ lưu' : 'Lưu địa danh',
      onPressed: _toggle,
      icon: Icon(
        _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      ),
    );
  }
}
