import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Pet',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DigitalPetApp(),
    );
  }
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});
  @override
  State<DigitalPetApp> createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp>
    with SingleTickerProviderStateMixin {
  String _petName = '';
  final TextEditingController _nameCtrl = TextEditingController();

  int _happiness = 50; // 0..100
  int _hunger = 50;    // 0..100
  double _energy = 0.6; // 0..1

  String _selectedActivity = 'Play';

  Timer? _hungerTimer; // every 30s hunger+5 (starving lowers happiness)
  Timer? _winTimer;    // track happiness>80 streak for 3 minutes
  Duration _happyStreak = Duration.zero;
  static const Duration _winTarget = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _hunger = (_hunger + 5).clamp(0, 100);
        if (_hunger >= 100) _happiness = (_happiness - 10).clamp(0, 100);
      });
      _checkLoss();
    });

    _winTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_happiness > 80) {
        _happyStreak += const Duration(seconds: 5);
        if (_happyStreak >= _winTarget) {
          _showDialog(
            title: 'You Win!',
            message:
                'Your pet stayed very happy for ${_winTarget.inMinutes} minutes! 🎉',
          );
          _happyStreak = Duration.zero;
        }
      } else {
        _happyStreak = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameCtrl.dispose();
    super.dispose();
  }

  // Actions
  void _playWithPet() {
    setState(() {
      _happiness = (_happiness + 10).clamp(0, 100);
      _hunger = (_hunger + 5).clamp(0, 100);
      _energy = (_energy - 0.05).clamp(0.0, 1.0);
    });
    _checkLoss();
  }

  void _feedPet() {
    setState(() {
      _hunger = (_hunger - 15).clamp(0, 100);
      _happiness = (_happiness + 5).clamp(0, 100);
      _energy = (_energy + 0.03).clamp(0.0, 1.0);
    });
  }

  void _applySelectedActivity() {
    setState(() {
      switch (_selectedActivity) {
        case 'Play':
          _happiness = (_happiness + 8).clamp(0, 100);
          _hunger = (_hunger + 5).clamp(0, 100);
          _energy = (_energy - 0.06).clamp(0.0, 1.0);
          break;
        case 'Feed':
          _hunger = (_hunger - 15).clamp(0, 100);
          _happiness = (_happiness + 4).clamp(0, 100);
          _energy = (_energy + 0.02).clamp(0.0, 1.0);
          break;
        case 'Nap':
          _energy = (_energy + 0.15).clamp(0.0, 1.0);
          _happiness = (_happiness + 2).clamp(0, 100);
          _hunger = (_hunger + 3).clamp(0, 100);
          break;
        case 'Walk':
          _happiness = (_happiness + 6).clamp(0, 100);
          _energy = (_energy - 0.04).clamp(0.0, 1.0);
          _hunger = (_hunger + 6).clamp(0, 100);
          break;
      }
    });
    _checkLoss();
  }

  String get _moodText {
    if (_happiness > 70) return 'Happy 😊';
    if (_happiness >= 30) return 'Neutral 😐';
    return 'Unhappy 😞';
  }

  Color _moodColor() {
    if (_happiness > 70) return Colors.green;
    if (_happiness >= 30) return Colors.yellow;
    return Colors.red;
  }

  void _checkLoss() {
    if (_hunger >= 100 && _happiness <= 10) {
      _showDialog(
        title: 'Game Over',
        message:
            'Your pet got too hungry and unhappy. Feed and play more next time!',
      );
    }
  }

  void _submitName() {
    final t = _nameCtrl.text.trim();
    if (t.isNotEmpty) setState(() => _petName = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_petName.isEmpty) ...[
                  Text('Name Your Pet',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Enter pet name',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _submitName(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitName,
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tip: Use a transparent PNG at assets/images/pet.png',
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text('Name: $_petName',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Mood: $_moodText',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),

                  AspectRatio(
                    aspectRatio: 1.4,
                    child: Center(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _moodColor(),
                          BlendMode.modulate,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/pet.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Missing pet image.\nPlace a transparent PNG at assets/images/pet.png\nand add it in pubspec.yaml.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _StatChip(label: 'Happiness', value: _happiness),
                      _StatChip(label: 'Hunger', value: _hunger),
                      _EnergyBar(value: _energy),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _playWithPet,
                        icon: const Icon(Icons.sports_esports),
                        label: const Text('Play'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _feedPet,
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Feed'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('Choose an Activity',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButton<String>(
                                value: _selectedActivity,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Play', child: Text('Play')),
                                  DropdownMenuItem(
                                      value: 'Feed', child: Text('Feed')),
                                  DropdownMenuItem(
                                      value: 'Nap', child: Text('Nap')),
                                  DropdownMenuItem(
                                      value: 'Walk', child: Text('Walk')),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedActivity = v);
                                  }
                                },
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _applySelectedActivity,
                                icon: const Icon(Icons.check),
                                label: const Text('Apply'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Activities change happiness, hunger, and energy.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _HappyProgress(streak: _happyStreak, target: _winTarget),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDialog({required String title, required String message}) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}

// UI helpers
class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  const _StatChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      avatar: CircleAvatar(
        child: Text(value.toString(), style: const TextStyle(fontSize: 11)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }
}

class _EnergyBar extends StatelessWidget {
  final double value; // 0..1
  const _EnergyBar({required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Energy'),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: value, minHeight: 10),
          ),
        ],
      ),
    );
  }
}

class _HappyProgress extends StatelessWidget {
  final Duration streak;
  final Duration target;
  const _HappyProgress({required this.streak, required this.target});
  @override
  Widget build(BuildContext context) {
    final ratio =
        (streak.inMilliseconds / target.inMilliseconds).clamp(0.0, 1.0);
    return Column(
      children: [
        Text(
          'Win Progress (Happy > 80 for ${target.inMinutes} min)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: ratio),
        const SizedBox(height: 4),
        Text('${streak.inSeconds}s / ${target.inSeconds}s'),
      ],
    );
  }
}
