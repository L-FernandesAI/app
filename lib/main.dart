import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

class ItemMovel {
  String tipo;
  double x;
  double y;
  double width;
  double height;

  ItemMovel({
    required this.tipo,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapeamento de Mesas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _ColorPickerDialog extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;

  const _ColorPickerDialog({
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color tempColor = currentColor;
    return AlertDialog(
      title: const Text('Escolha a Cor de Fundo'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: tempColor,
          onColorChanged: (color) {
            tempColor = color;
          },
          enableAlpha: false,
          showLabel: false,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Aplicar'),
          onPressed: () {
            onColorChanged(tempColor);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ItemMovel> itens = [];
  int? selectedIndex;
  double gridSize = 50;
  bool isPanelVisible = true;
  Color backgroundColor = Colors.white;

  void addItem(String tipo) {
    double defaultWidth = tipo == 'mesa'
        ? 100
        : tipo == 'cadeira'
            ? 40
            : tipo == 'parede'
                ? 120
                : 80;
    double defaultHeight = tipo == 'mesa'
        ? 100
        : tipo == 'cadeira'
            ? 40
            : tipo == 'parede'
                ? 20
                : 20;

    setState(() {
      itens.add(ItemMovel(
        tipo: tipo,
        x: 100,
        y: 100,
        width: defaultWidth,
        height: defaultHeight,
      ));
      selectedIndex = itens.length - 1;
      isPanelVisible = true;
    });
  }

  void ajustarTamanho(bool aumentar) {
    if (selectedIndex == null) return;
    setState(() {
      final item = itens[selectedIndex!];
      final fator = aumentar ? 1.1 : 0.9;
      item.width *= fator;
      item.height *= fator;
    });
  }

  void deletarItem() {
    if (selectedIndex == null) return;
    setState(() {
      itens.removeAt(selectedIndex!);
      selectedIndex = null;
    });
  }

  void abrirSeletorDeCor() {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        currentColor: backgroundColor,
        onColorChanged: (color) {
          setState(() {
            backgroundColor = color;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salão do Restaurante'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            tooltip: 'Cor do Fundo',
            onPressed: abrirSeletorDeCor,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fundo com cor personalizada
          Container(
            color: backgroundColor,
            child: CustomPaint(
              size: Size.infinite,
              painter: GridPainter(gridSize: gridSize),
            ),
          ),

          // Itens interativos
          ...List.generate(itens.length, (index) {
            final item = itens[index];
            final isSelected = selectedIndex == index;

            return Positioned(
              left: item.x,
              top: item.y,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                    isPanelVisible = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    item.x += details.delta.dx;
                    item.y += details.delta.dy;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    item.x = (item.x / gridSize).round() * gridSize;
                    item.y = (item.y / gridSize).round() * gridSize;
                  });
                },
                child: Container(
                  width: item.width,
                  height: item.height,
                  decoration: BoxDecoration(
                    color: item.tipo == 'mesa'
                        ? Colors.brown
                        : item.tipo == 'cadeira'
                            ? Colors.blue
                            : item.tipo == 'parede'
                                ? Colors.black
                                : Colors.green[400],
                    border: isSelected
                        ? Border.all(color: Colors.redAccent, width: 2)
                        : null,
                    borderRadius: item.tipo == 'cadeira'
                        ? BorderRadius.circular(20)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      item.tipo.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // Painel inferior retrátil
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isPanelVisible ? 100 : 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                border: const Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                children: [
                  if (isPanelVisible && selectedIndex != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, size: 30),
                          tooltip: 'Aumentar',
                          onPressed: () => ajustarTamanho(true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 30),
                          tooltip: 'Diminuir',
                          onPressed: () => ajustarTamanho(false),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 30),
                          tooltip: 'Excluir',
                          onPressed: deletarItem,
                        ),
                      ],
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(
                        isPanelVisible
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          isPanelVisible = !isPanelVisible;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu de adicionar itens
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => addItem('mesa'),
                  child: const Text('Mesa'),
                ),
                ElevatedButton(
                  onPressed: () => addItem('cadeira'),
                  child: const Text('Cadeira'),
                ),
                ElevatedButton(
                  onPressed: () => addItem('parede'),
                  child: const Text('Parede'),
                ),
                ElevatedButton(
                  onPressed: () => addItem('listra'),
                  child: const Text('Faixa'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor da grade
class GridPainter extends CustomPainter {
  final double gridSize;
  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
