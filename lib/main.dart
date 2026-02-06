import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class ImageButtonData extends ChangeNotifier {
  String _selectedId;
  final List<Map<String, String>> _buttons;

  ImageButtonData({required List<Map<String, String>> buttons})
    : _buttons = buttons,
      _selectedId = buttons.isNotEmpty ? buttons[0]['id']! : '';

  String get selectedId => _selectedId;

  List<Map<String, String>> get buttons => _buttons;

  void selectButton(String id) {
    if (_selectedId != id) {
      _selectedId = id;
      notifyListeners();
    }
  }
}

class ImgButton extends StatelessWidget {
  final String id;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final double itemDiameter;
  final Color itemColor;
  final double borderThickness;
  final double lineThickness;

  const ImgButton({
    super.key,
    required this.id,
    required this.imageUrl,
    this.isSelected = false,
    required this.onTap,
    this.itemDiameter = 90.0,
    this.itemColor = const Color.fromARGB(255, 194, 145, 1),
    this.borderThickness = 4.0,
    this.lineThickness = 4.0,
  });

  static const double _kVerticalSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final double innerSize = itemDiameter - (borderThickness * 2);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: itemDiameter,
            height: itemDiameter,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: itemColor, width: borderThickness)
                  : Border.all(color: itemColor, width: 2),
            ),
            child: ClipOval(
              child: ColoredBox(
                color: Colors.grey.shade200,
                child: Image.network(
                  imageUrl,
                  width: innerSize,
                  height: innerSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.black45,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: _kVerticalSpacing),
              width: itemDiameter * 0.9,
              height: lineThickness,
              decoration: BoxDecoration(
                color: itemColor,
                borderRadius: BorderRadius.circular(lineThickness / 2),
              ),
            ),
        ],
      ),
    );
  }
}

class HeroPage extends StatelessWidget {
  final String selectedId;

  const HeroPage({super.key, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 68, 34, 0),
        border: Border.all(
          color: const Color.fromARGB(255, 189, 88, 0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Hero Page (dummy)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selected button: $selectedId',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ImageButtonData>(
      create: (BuildContext context) => ImageButtonData(
        buttons: <Map<String, String>>[
          <String, String>{
            'id': 'option1',
            'imageUrl': 'https://picsum.photos/seed/option1/200',
          },
          <String, String>{
            'id': 'option2',
            'imageUrl': 'https://picsum.photos/seed/option2/200',
          },
          <String, String>{
            'id': 'option3',
            'imageUrl': 'https://picsum.photos/seed/option3/200',
          },
          <String, String>{
            'id': 'option4',
            'imageUrl': 'https://picsum.photos/seed/option4/200',
          },
        ],
      ),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<ImageButtonData>(
              builder:
                  (
                    BuildContext context,
                    ImageButtonData imageData,
                    Widget? child,
                  ) {
                    if (imageData.buttons.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 121, 57, 0),
                        border: Border.all(
                          color: const Color.fromARGB(255, 189, 88, 0),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: imageData.buttons.map<Widget>((
                            Map<String, String> buttonMap,
                          ) {
                            final String id = buttonMap['id']!;
                            final String imageUrl = buttonMap['imageUrl']!;
                            final bool isSelected = imageData.selectedId == id;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: ImgButton(
                                id: id,
                                imageUrl: imageUrl,
                                isSelected: isSelected,
                                onTap: () => imageData.selectButton(id),
                                itemDiameter: 90.0,
                              ),
                            );
                          }).toList(),
                        ),
                     
                    );
                  },
            ),
            const SizedBox(height: 16),
            Consumer<ImageButtonData>(
              builder:
                  (
                    BuildContext context,
                    ImageButtonData imageData,
                    Widget? child,
                  ) {
                    return HeroPage(selectedId: imageData.selectedId);
                  },
            ),
          ],
        ),
      ),
    );
  }
}
