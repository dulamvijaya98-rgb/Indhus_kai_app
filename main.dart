import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'draggable_sticker_widget.dart';

void main() {
  runApp(const IndhusKaiApp());
}

class IndhusKaiApp extends StatelessWidget {
  const IndhusKaiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Indhu'sKai App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const DiaryHome(),
    );
  }
}

class DiaryHome extends StatefulWidget {
  const DiaryHome({super.key});
  @override
  State<DiaryHome> createState() => _DiaryHomeState();
}

class _DiaryHomeState extends State<DiaryHome> {
  final PageController _pageController = PageController();
  final AudioPlayer _player = AudioPlayer();

  // Simple in-memory pages
  final List<DiaryPageData> pages = List.generate(
    5,
    (i) => DiaryPageData(pageNumber: i + 1, text: ""),
  );

  @override
  void dispose() {
    _player.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndPlaySongForPage(int pageIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        await _player.setFilePath(path);
        _player.play();
        setState(() {
          pages[pageIndex].songPath = path;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Playing: ${result.files.single.name}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error picking song")));
    }
  }

  void _stopSong() => _player.stop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Indhu'sKai App 💗"),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return DiaryPageWidget(
            pageData: pages[index],
            onLastLineFilled: () {
              if (index < pages.length - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
              } else {
                // add one more page
                setState(() {
                  pages.add(DiaryPageData(pageNumber: pages.length + 1, text: ""));
                });
                _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
              }
            },
            onPickSong: () => _pickAndPlaySongForPage(index),
            onStopSong: _stopSong,
          );
        },
      ),
    );
  }
}

class DiaryPageData {
  int pageNumber;
  String text;
  String? songPath;
  List<StickerData> stickers = [];

  DiaryPageData({required this.pageNumber, this.text = ""});
}

class StickerData {
  String assetPath;
  double x;
  double y;
  double scale;
  StickerData({required this.assetPath, this.x = 100, this.y = 100, this.scale = 1.0});
}

class DiaryPageWidget extends StatefulWidget {
  final DiaryPageData pageData;
  final VoidCallback onLastLineFilled;
  final VoidCallback onPickSong;
  final VoidCallback onStopSong;

  const DiaryPageWidget({
    required this.pageData,
    required this.onLastLineFilled,
    required this.onPickSong,
    required this.onStopSong,
    super.key,
  });

  @override
  State<DiaryPageWidget> createState() => _DiaryPageWidgetState();
}

class _DiaryPageWidgetState extends State<DiaryPageWidget> {
  final TextEditingController _controller = TextEditingController();
  List<StickerData> stickers = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.pageData.text;
    stickers = widget.pageData.stickers;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSticker() {
    setState(() {
      final s = StickerData(assetPath: 'assets/stickers/magic_star.png', x: 80, y: 200, scale: 1.0);
      stickers.add(s);
      widget.pageData.stickers = stickers;
    });
  }

  void _openAIPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.pink.shade50.withOpacity(0.95),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Kai says: Keep shining, Indhu! 🌟✨", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Lottie.asset('assets/animations/kai_sparkle.json', width: 120, height: 120, repeat: false),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Thanks Kai"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // background
      Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      // sparkles
      Positioned.fill(child: Opacity(opacity: 0.9, child: Lottie.asset('assets/animations/magic_sparkles.json', fit: BoxFit.cover))),
      // border (simple)
      Positioned.fill(
        child: IgnorePointer(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: Colors.pinkAccent, width: 4), borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      // text field
      Padding(
        padding: const EdgeInsets.fromLTRB(36, 28, 36, 120),
        child: TextField(
          controller: _controller,
          maxLines: null,
          style: const TextStyle(fontSize: 18, fontFamily: 'DancingScript', color: Colors.brown, height: 1.7),
          decoration: const InputDecoration(border: InputBorder.none, hintText: "Write your magical diary..."),
          onChanged: (v) {
            widget.pageData.text = v;
          },
          onEditingComplete: widget.onLastLineFilled,
        ),
      ),
      // stickers
      ...stickers.map((s) => DraggableStickerWidget(
            key: UniqueKey(),
            assetPath: s.assetPath,
            initialX: s.x,
            initialY: s.y,
            initialScale: s.scale,
            onUpdate: (x, y, scale) {
              s.x = x;
              s.y = y;
              s.scale = scale;
            },
          )),
      // bottom controls
      Positioned(
        bottom: 14,
        left: 14,
        right: 14,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.small(onPressed: _addSticker, child: const Icon(Icons.emoji_emotions)),
            Row(children: [
              IconButton(icon: const Icon(Icons.music_note, color: Colors.green), onPressed: widget.onPickSong),
              IconButton(icon: const Icon(Icons.stop, color: Colors.red), onPressed: widget.onStopSong),
              IconButton(icon: const Icon(Icons.auto_awesome, color: Colors.purple), onPressed: _openAIPopup),
            ]),
          ],
        ),
      ),
    ]);
  }
}
