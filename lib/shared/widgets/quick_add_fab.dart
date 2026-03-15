import 'package:flutter/material.dart';

class QuickAddFAB extends StatefulWidget {
  final VoidCallback onTextLog;
  final VoidCallback onScanBarcode;
  final VoidCallback onVoiceLog;

  const QuickAddFAB({
    super.key,
    required this.onTextLog,
    required this.onScanBarcode,
    required this.onVoiceLog,
  });

  @override
  State<QuickAddFAB> createState() => _QuickAddFABState();
}

class _QuickAddFABState extends State<QuickAddFAB>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _buildActionItem(
            icon: Icons.mic,
            label: 'Voice Log',
            onTap: widget.onVoiceLog,
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            icon: Icons.qr_code_scanner,
            label: 'Scan Barcode',
            onTap: widget.onScanBarcode,
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            icon: Icons.text_snippet,
            label: 'Text Log',
            onTap: widget.onTextLog,
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          heroTag: 'quick_add_fab',
          onPressed: _toggle,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              _toggle();
              onTap();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _toggle();
                onTap();
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
