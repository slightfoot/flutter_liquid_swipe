import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  static const colors = <Color>[
    const Color(0xFFFFFFFF),
    const Color(0xFF5D11F7),
    const Color(0xFFFF5A3C),
    const Color(0xFF1F036C),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: LiquidSwipePager(
        itemCount: colors.length,
        itemBuilder: (BuildContext context, int index) {
          return ExamplePage(
            index: index,
            color: colors[index],
          );
        },
      ),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({
    Key key,
    @required this.index,
    @required this.color,
  }) : super(key: key);

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 24.0, 8.0, 64.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'GameCoin',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: index.isEven ? const Color(0xB6000000) : const Color(0xB6FFFFFF),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {},
                    shape: const StadiumBorder(),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: index.isEven ? Colors.lightBlue : const Color(0xFFFF5A85),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    index.isEven ? 'assets/firstPageImage.png' : 'assets/secondPageImage.png',
                  ),
                ),
              ),
              Align(
                heightFactor: 0.75,
                alignment: Alignment.bottomLeft,
                child: Text(
                  index.isEven ? 'Online' : 'For',
                  style: TextStyle(
                    fontSize: 32.0,
                    color: index.isEven ? const Color(0x55000000) : const Color(0x99FF5A85),
                  ),
                ),
              ),
              Align(
                heightFactor: 0.8,
                alignment: Alignment.bottomLeft,
                child: Text(
                  index.isEven ? 'Gambling' : 'Gamers',
                  style: TextStyle(
                    fontSize: 56.0,
                    color: index.isEven ? const Color(0xFF000000) : const Color(0xFFFF5A85),
                    fontWeight: index.isEven ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
              Text(
                index.isEven
                    ? 'Temporibus autem aut\nofficiis debitis aut rerum\nnecessitatibus'
                    : 'Excepteur sint occaecat cupidatat\nnon proident, sunt in\nculpa qui officia',
                style: const TextStyle(
                  color: const Color(0xFFB5B5B5),
                ),
              ),
              SizedBox(height: 16.0),
              Image.asset(
                index.isEven ? 'assets/firstPagePager.png' : 'assets/secondPagePager.png',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
