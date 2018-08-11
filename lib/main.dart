import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "shoppinglist.dart";

List<String> mayhem_array=[];
String passed_data;
ShoppingList currentlist=new ShoppingList();

Key gochakey;
void main() {
  runApp(SampleApp());
}

class SampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleAppPage(),
      routes: <String, WidgetBuilder> {
        '/item': (BuildContext context) => ItemPage(),
      }
    );
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  TextStyle gridstyle;
  @override
  Widget build(BuildContext context) {
    gochakey = new Key("really");
    gridstyle = new TextStyle(fontSize: 18.0);
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample App"),
      ),
      //body: ListView(children: _getListData()),
      body:Column(children: bigTyme())
    );
  }

  bigTyme() {
    List<Widget> widgets = [];
    widgets.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Text("This is a header section"),
        new Text("total price")
      ],
    ));

    widgets.add(new Expanded(
        child:ListView(key:gochakey,children: _getListData())
      )
    );
    widgets.add(new Row(
      children: <Widget>[
        new CupertinoButton(child: new Text("Add Item"),
        onPressed: (){
          setState(()
          {
            int ct=mayhem_array.length;
            mayhem_array.add("BOO $ct");
          });
          //ListView(key:gochakey,children:_getListData());
        }
        )
      ],
    ));
    return widgets;
  }

  _getListData() {
    List<Widget> widgets = [];
    if(mayhem_array.isEmpty){
      //mayhem_array.addAll(["A","B","C","D","E"]);
      mayhem_array.addAll(currentlist.getList());
    }
    for (int i = 0; i < mayhem_array.length; i++) {
      //widgets.add(Spacer());
      widgets.add(GestureDetector(
        child:Padding(
            padding: EdgeInsets.all(10.0),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(
              child: new Text('Deliver features faster', style:gridstyle,textAlign: TextAlign.center),
            ),
            new Expanded(
              child: new Text("Row "+mayhem_array[i], style:gridstyle, textAlign: TextAlign.center),
            ),

            new Expanded(
              child: new IconButton(icon: Icon(CupertinoIcons.info), onPressed: ()async {
                //print("start editing for "+mayhem_array[i]);
                passed_data=mayhem_array[i];
                Object info = await Navigator.of(context).pushNamed("/item");
                print(info);
              })
            )

            /*
            new Expanded(
              child: new FittedBox(
                fit: BoxFit.scaleDown, // otherwise the logo will be tiny
                child: const FlutterLogo(),
              ),
            ),
            */
          ],
        )
      ),

        /*
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Row $i"),
        ),
        */
        onTap: () {
          print('row tapped '+mayhem_array[i]);
        },
      ));
    }
    return widgets;
  }
}



class ItemPage extends StatefulWidget {
  ItemPage({Key key}) : super(key: key);


  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  TextStyle gridstyle;
  String needed;

  // Create a text controller and use it to retrieve the current value.
  // of the TextField!
  final totalController = TextEditingController(text:"0.54");
  final detailsController= TextEditingController();
  final nameController= TextEditingController(text:passed_data);
  final qtyController= TextEditingController(text:"1");

  @override
  void dispose() {
    // Clean up the controller when disposing of the Widget.
    totalController.dispose();
    detailsController.dispose();
    nameController.dispose();
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gridstyle = new TextStyle(fontSize: 16.0);
    needed = passed_data;
    //nameController.text=needed;
    //qtyController.text="1";

    return Scaffold(
        appBar: AppBar(
          title: Text("Editing Item '$needed'"),
        ),
        //body: ListView(children: _getListData()),
        //body: Column(children: [new Text(needed)])
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            //style:gridstyle,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: qtyController,
            decoration: InputDecoration(hintText: "Qty"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            //style:gridstyle,
            controller: nameController,
            decoration: InputDecoration(hintText: "Item Name"),

          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
           // style:gridstyle,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: totalController,
            decoration: InputDecoration(hintText: "Total Price"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
           // style:gridstyle,
            maxLines:null,
            controller: detailsController,
            decoration: InputDecoration(hintText: "Details"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: CupertinoButton(child:Text("Save"),onPressed: (){
            //TODO:validate the data, back off if not good, else create an Item object and add to ShoppingList
            Navigator.of(context).pop({
              "qty":qtyController.text,
              "name":nameController.text,
              "total":totalController.text
            });
          },)
        )

      ])




    );
  }
}