import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ashu',
      home: MyHomePage(title: 'XO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String last = '', b4Last = '', surroundingGrid;
  Set xList = {}, oList = {}, winList = {};
  Set allWinList = {}, legalMoves = {}, lastAddedLegalMoves = {};
  bool sw = true, xTurn = true;
  bool win = false, xWin = false, oWin = false, undo = false, dark = false;
  int i, j, ii, jj, t;
  int w = 0, rc = 0, cc = 0, start = 5, nor = 12, noc = 20;

  @override
  Widget build(BuildContext context) {
//SystemChrome.setEnabledSystemUIOverlays([]);
    systemTheme();

    return Scaffold(
        bottomNavigationBar: Container(
            height: 40,
            color: dark ? Colors.black : Colors.white,
            child: Row(children: <Widget>[undoButton(), resetButton()])),
        appBar: AppBar(
            brightness: dark ? Brightness.dark : Brightness.light,
            actions: /*<Widget>*/ [themeButton()],
            backgroundColor: dark ? Colors.black : Colors.white,
            title: Text(
              xWin || oWin
                  ? xWin ? 'X Win' : 'O Win'
                  : xTurn ? 'X Turn' : 'O Turn',
              style: TextStyle(color: dark ? Colors.white : Colors.black),
            )),
        body: GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity > 500 && start == 5) {
                start = 0;
                setState(() {});
              }
              if (details.primaryVelocity < -500 && start == 5) {
                start = 10;
                setState(() {});
              }
              if (details.primaryVelocity > 500 && (start == 10) ||
                  details.primaryVelocity < -500 && start == 0) {
                start = 5;
                setState(() {});
              }
            },
            child: Container(
                color: Colors.black45,
                child: Column(children: <Widget>[
                  horizontalBorder(),
                  for (i = 0; i < noc; i++) c(i),
                  horizontalBorder()
                ]))));
  }

  c(int i) {
    return Expanded(
        child: Row(children: /*<Widget>*/ [
      verticalBorder(),
      for (j = start; j < nor + start; j++) r(i, j),
      verticalBorder()
    ]));
  }

  r(int i, int j) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.all(0.5),
            child: Container(
                color: last == '$i,$j' || (b4Last == '$i,$j' && undo)
                    ? dark ? Color(0xff202020) : Color(0xffe0e0e0)
                    : dark ? Colors.black : Colors.white,
                child: InkWell(
                    child: xList.contains('$i,$j') || oList.contains('$i,$j')
                        ? xList.contains('$i,$j')
                            ? Center(
                                child: Text('X',
                                    style: TextStyle(
                                        color:
                                            win && allWinList.contains('$i,$j')
                                                ? Colors.green
                                                : dark
                                                    ? Colors.white
                                                    : Colors.black)))
                            : Center(
                                child: Text('O',
                                    style: TextStyle(
                                        color:
                                            win && allWinList.contains('$i,$j')
                                                ? Colors.green
                                                : Colors.red)))
                        : Center(child: Text('')),
                    onTap: () {
                      setState(() {
                        undo = false;
                        if (!win) {
                          if (!xList.contains('$i,$j') &&
                              !oList.contains('$i,$j') &&
                              (legalMoves.contains('$i,$j') ||
                                  legalMoves.isEmpty)) {
                            xTurn ? xList.add('$i,$j') : oList.add('$i,$j');
                            b4Last = last;
                            last = '$i,$j';
                            lastAddedLegalMoves.clear();

                            for (ii = -1; ii < 2; ii++) {
                              for (jj = -1; jj < 2; jj++) {
                                if (ii != 0 || jj != 0) {
                                  surroundingGrid = '${i + ii},${j + jj}';
                                  legalMovesMaking();
                                }
                              }
                            }
                            xTurn = !xTurn;
                          }
                          if (!xTurn) {
                            xWin = checkXWin1(i, j) +
                                    checkXWin2(i, j) +
                                    checkXWin3(i, j) +
                                    checkXWin4(i, j) >
                                0;
                          } else {
                            oWin = checkOWin1(i, j) +
                                    checkOWin2(i, j) +
                                    checkOWin3(i, j) +
                                    checkOWin4(i, j) >
                                0;
                          }
                          if (xWin || oWin) {
                            win = true;
                          }
                        }
                      });
                    }))));
  }

  int checkXWin1(int i, int j) {
    winList.add('$i,$j');
    for (ii = i + 1; ii < i + 5; ii++) {
      if (xList.contains('$ii,$j')) {
        w += 1;
        winList.add('$ii,$j');
      } else
        ii = i + 5;
    }
    for (ii = i - 1; ii > i - 5; ii--) {
      if (xList.contains('$ii,$j')) {
        w += 1;
        winList.add('$ii,$j');
      } else {
        ii = i - 5;
      }
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  int checkOWin1(int i, int j) {
    winList.add('$i,$j');
    for (ii = i + 1; ii < i + 5; ii++) {
      if (oList.contains('$ii,$j')) {
        winList.add('$ii,$j');
        w += 1;
      } else
        ii = i + 5;
    }
    for (ii = i - 1; ii > i - 5; ii--) {
      if (oList.contains('$ii,$j')) {
        winList.add('$ii,$j');
        w += 1;
      } else
        ii = i - 5;
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  int checkXWin2(int i, int j) {
    winList.add('$i,$j');
    jj = j + 1;
    for (ii = i - 1; ii > i - 5; ii--, jj++) {
      if (xList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i - 5;
    }
    jj = j - 1;
    for (ii = i + 1; ii < i + 5; ii++, jj--) {
      if (xList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i + 5;
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  int checkOWin2(int i, int j) {
    winList.add('$i,$j');
    jj = j + 1;
    for (ii = i - 1; ii > i - 5; ii--, jj++) {
      if (oList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i - 5;
    }
    jj = j - 1;
    for (ii = i + 1; ii < i + 5; ii++, jj--) {
      if (oList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i + 5;
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  int checkXWin3(int i, int j) {
    winList.add('$i,$j');
    for (jj = j + 1; jj < j + 5; jj++) {
      if (xList.contains('$i,$jj')) {
        winList.add('$i,$jj');
        w += 1;
      } else
        jj = j + 5;
    }
    for (jj = j - 1; jj > j - 5; jj--) {
      if (xList.contains('$i,$jj')) {
        winList.add('$i,$jj');
        w += 1;
      } else
        jj = j - 5;
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  int checkOWin3(int i, int j) {
    winList.add('$i,$j');
    for (jj = j + 1; jj < j + 5; jj++) {
      if (oList.contains('$i,$jj')) {
        winList.add('$i,$jj');
        w += 1;
      } else
        jj = j + 5;
    }
    for (jj = j - 1; jj > j - 5; jj--) {
      if (oList.contains('$i,$jj')) {
        winList.add('$i,$jj');
        w += 1;
      } else
        jj = j - 5;
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  int checkXWin4(int i, int j) {
    winList.add('$i,$j');
    jj = j + 1;
    for (ii = i + 1; ii < i + 5; ii++, jj++) {
      if (xList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i + 5;
    }
    jj = j - 1;
    for (ii = i - 1; ii > i - 5; ii--, jj--) {
      if (xList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i - 5;
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  int checkOWin4(int i, int j) {
    winList.add('$i,$j');
    jj = j + 1;
    for (ii = i + 1; ii < i + 5; ii++, jj++) {
      if (oList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i + 5;
    }
    jj = j - 1;
    for (ii = i - 1; ii > i - 5; ii--, jj--) {
      if (oList.contains('$ii,$jj')) {
        winList.add('$ii,$jj');
        w += 1;
      } else
        ii = i - 5;
    }
    if (w > 3) {
      w = 0;
      allWinList = allWinList.union(winList);
      return 1;
    }
    w = 0;
    winList.clear();
    return 0;
  }

  undoButton() {
    return Expanded(
        child: MaterialButton(
            color: dark ? Colors.black : Colors.white,
            child: Row(children: [
              Expanded(
                  child: Icon(Icons.undo,
                      size: 20, color: dark ? Colors.white : Colors.black)),
              Expanded(
                  child: Text('UNDO',
                      style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white : Colors.black)))
            ]),
            onPressed: () {
              setState(() {
                if (last != b4Last && !win) {
                  xTurn ? oList.remove(last) : xList.remove(last);
                  xTurn = !xTurn;
                  undo = !undo;
                  last = b4Last;
                  legalMoves.removeAll(lastAddedLegalMoves);
                }
              });
            }));
  }

  resetButton() {
    return Expanded(
        child: MaterialButton(
            color: dark ? Colors.black87 : Colors.white,
            child: Row(children: [
              Expanded(
                  child: Icon(Icons.settings_backup_restore,
                      size: 20, color: dark ? Colors.white : Colors.black)),
              Expanded(
                  child: Text('RESET',
                      style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white : Colors.black)))
            ]),
            onPressed: () {
              setState(() {
                start = 5;
                win = false;
                xWin = false;
                oWin = false;
                xTurn = true;
                xList.clear();
                oList.clear();
                legalMoves.clear();
                allWinList.clear();
                last = b4Last = '';
              });
            }));
  }

  themeButton() {
    return Container(
        width: 60,
        child: MaterialButton(
            child: Icon(!dark ? Icons.brightness_4 : Icons.brightness_7,
                color: dark ? Colors.white : Colors.black),
            onPressed: () {
              setState(() {
                dark = !dark;
                systemTheme();
//                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//                    statusBarColor: dark?Colors.black:Colors.white,
//                    systemNavigationBarColor:
//                        dark ? Colors.black : Colors.white,
//                    systemNavigationBarIconBrightness:
//                        dark ? Brightness.light : Brightness.dark));
              });
            }));
  }

  verticalBorder() {
    return Container(
        width: 10,
        color: dark ? Colors.black : Colors.white,
        child: InkWell(
            child: Center(
                child: Text('${String.fromCharCode(i + 65)}',
                    style: TextStyle(
                        fontSize: 7,
                        color: dark ? Colors.white54 : Colors.black)))));
  }

  horizontalBorder() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(children: <Widget>[
          for (t = start; t < start + nor; t++)
            Expanded(
                child: Container(
                    height: 10,
                    color: dark ? Colors.black : Colors.white,
                    child: InkWell(
                        child: Center(
                            child: Text('${t + 1}',
                                style: TextStyle(
                                    fontSize: 7,
                                    color: dark
                                        ? Colors.white54
                                        : Colors.black))))))
        ]));
  }

  void legalMovesMaking() {
    if (!xList.contains(surroundingGrid) &&
        !oList.contains(surroundingGrid) &&
        !legalMoves.contains(surroundingGrid)) {
      legalMoves.add(surroundingGrid);
      lastAddedLegalMoves.add(surroundingGrid);
    }
  }

  void systemTheme() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: dark ? Colors.black : Colors.white,
        systemNavigationBarColor: dark ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark));
  }
}
