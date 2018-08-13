import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "shoppinglist.dart";
import "shoppingitem.dart";

List<ShoppingItem> mayhemArray=[];

ShoppingItem passedInData;
ShoppingList currentlist;
String runningTotal="\$0.00";

Key gochakey;
Key totalkey;
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
    totalkey = new Key("runningtotal");
    gridstyle = new TextStyle(fontSize: 18.0);
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample App"),
      ),
      //body: ListView(children: _getListData()),
      body:Column(children: bigTyme())
    );
  }

  doAlertDialog(String prompt,List<String> buttons)
  {
    List<Widget> action_pack = [];
    var count=buttons.length;
    assert(count > 0);
    for(var i=0;i<count;i++)
      {
        action_pack.add(
          new FlatButton(
            child: new Text(buttons[i]),
            onPressed: () {
              var onefirst=i+1;
              Navigator.pop(context,"$onefirst");
            },
          ),
        );
      }
    return showDialog(context: this.context,
      builder: (BuildContext context) {
        return new AlertDialog(
          content: new Text(prompt),
          actions: action_pack
        );
      },
    );
  }
  bigTyme() {
    List<Widget> widgets = [];
    widgets.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Text("This is a header section"),
        new Text("Estimated total: "+runningTotal,key:totalkey)
      ],
    ));

    widgets.add(new Expanded(
        child:ListView(key:gochakey,children: _getListData())
      )
    );
    widgets.add(new Row(
      children: <Widget>[
        new CupertinoButton(child: new Text("Add Item"),
        onPressed: () async {
          passedInData = ShoppingItem.createBlank();
          Object info = await Navigator.of(context).pushNamed("/item") as String;
          if(info != null)
          {
            Object gotem = await doAlertDialog(info,["OK"]) as String;
            setState(()
            {
              mayhemArray.clear(); //force a reload
              currentlist.addItem(passedInData.id);
              runningTotal=currentlist.runningTotal;
            });
            //alert
          }
          //ListView(key:gochakey,children:_getListData());
        }
        )
      ],
    ));
    return widgets;
  }

  _getListData() {
    List<Widget> widgets = [];
    if(currentlist==null)
      {
        currentlist=new ShoppingList();
      }
    if(mayhemArray.isEmpty){
      //mayhemArray.addAll(["A","B","C","D","E"]);
      mayhemArray.addAll(currentlist.getList());
    }
    for (int i = 0; i < mayhemArray.length; i++) {
      //widgets.add(Spacer());
      List<Widget> rowContent=[];
      rowContent.add(
          new Expanded(
            flex:2,
        child: new Text(mayhemArray[i].fmtQty, style:gridstyle,textAlign: TextAlign.center),
      ));
      if(mayhemArray[i].qty >0)
      {
        rowContent.add(
            new Expanded(
              flex:2,
                child: new FlatButton(
                  child:new Icon(CupertinoIcons.minus_circled),
                  onPressed: () async {
                    Object gotem = await doAlertDialog("Remove item '${mayhemArray[i].name}' from what you're buying?",["Yes","No"]) as String;
                    if(gotem=="1")
                    {
                      currentlist.removeItem(mayhemArray[i]);
                      setState((){
                        mayhemArray.clear(); //force a reload
                        runningTotal=currentlist.runningTotal;
                      });
                    }
                  },
                )
            )
        );
      }
      else
      {
        rowContent.add(
            new Expanded(
              child: new FittedBox(
                fit: BoxFit.scaleDown, // make the logo will be tiny
                child: const FlutterLogo(),
              ),
            )
        );
      }
      rowContent.addAll([
        new Expanded(
          flex:6,
          child: new Text(mayhemArray[i].name, style:gridstyle, textAlign: TextAlign.start,maxLines: 3,),
        ),
        new Expanded(
          flex:3,
          child: new Text(mayhemArray[i].fmtTotal, style:gridstyle,textAlign: TextAlign.center),
        ),
        new Expanded(
            flex:0,
            child: new IconButton(icon: Icon(CupertinoIcons.info), onPressed: ()async {
              //print("start editing for "+mayhemArray[i]);
              passedInData=mayhemArray[i];
              Object info = await Navigator.of(context).pushNamed("/item") as String;
              if(info != null)
              {
                Object gotem = await doAlertDialog(info,["OK"]) as String;
                setState(()
                {
                  runningTotal=currentlist.runningTotal;
                });
                //alert
              }
            })
        )
      ]);


      widgets.add(GestureDetector(
        child:Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowContent,
          /*
          children: <Widget>[

            new Expanded(
              child: new Text(mayhemArray[i].fmtQty, style:gridstyle,textAlign: TextAlign.center),
            ),
            new Expanded(
                child: new FlatButton(
                  child:new Text("Remove"),
                  onPressed: () async {
                    Object gotem = await doAlertDialog("Remove item '${mayhemArray[i].name}' from what you're buying?",["Yes","No"]) as String;
                    if(gotem=="1")
                      {
                        currentlist.removeItem(mayhemArray[i]);
                        setState((){
                          mayhemArray.clear(); //force a reload
                          runningTotal=currentlist.runningTotal;
                        });
                      }
                  },
                )
            ),
            new Expanded(
              child: new Text(mayhemArray[i].name, style:gridstyle, textAlign: TextAlign.center),
            ),
            new Expanded(
              child: new Text(mayhemArray[i].fmtTotal, style:gridstyle,textAlign: TextAlign.center),
            ),
            new Expanded(
              child: new IconButton(icon: Icon(CupertinoIcons.info), onPressed: ()async {
                //print("start editing for "+mayhemArray[i]);
                passedInData=mayhemArray[i];
                Object info = await Navigator.of(context).pushNamed("/item") as String;
                if(info != null)
                {
                  Object gotem = await doAlertDialog(info,["OK"]) as String;
                  print(gotem);
                  setState(()
                  {
                    runningTotal=currentlist.runningTotal;
                  });
                  //alert
                }
              })
            )
            */

            /*
            new Expanded(
              child: new FittedBox(
                fit: BoxFit.scaleDown, // otherwise the logo will be tiny
                child: const FlutterLogo(),
              ),
            ),

          ],
                */
        )
      ),

        /*
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Row $i"),
        ),
        */
        onTap: () {
          //print('row tapped '+mayhemArray[i]);
          //TODO:this may serve no use
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


  final totalController = TextEditingController(text:passedInData.fmtTotal.substring(1));
  final detailsController= TextEditingController(text:passedInData.notes);
  final nameController= TextEditingController(text:passedInData.name);
  final qtyController= TextEditingController(text:passedInData.fmtQty);

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
    needed = passedInData.name;
    String barTitle;
    if(needed.isEmpty)
    {
      barTitle = "Adding New Item";
    }
    else
    {
      barTitle = "Editing Item '$needed'";
    }
    //nameController.text=needed;
    //qtyController.text="1";

    return Scaffold(
        appBar: AppBar(
          title: Text(barTitle),
        ),
        //body: ListView(children: _getListData()),
        //body: Column(children: [new Text(needed)])
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TextField(
            //style:gridstyle,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: qtyController,
            decoration: InputDecoration(hintText: "Qty"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TextField(
            //style:gridstyle,
            controller: nameController,
            decoration: InputDecoration(hintText: "Item Name"),

          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TextField(
           // style:gridstyle,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: totalController,
            decoration: InputDecoration(hintText: "Total Price"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TextField(
           // style:gridstyle,
            maxLines:null,
            controller: detailsController,
            decoration: InputDecoration(hintText: "Details"),
          ),
        ),

        Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: CupertinoButton(child:Text("Save"),onPressed: (){
            //TODO:validate the data, back off if not good, else create an Item object and add to ShoppingList
            var isNew = (passedInData.id == -1);

            if(passedInData != null) {
              passedInData.update(
                  qty: qtyController.text.trim(),
                  name: nameController.text.trim(),
                  total: totalController.text.trim(),
                  details: detailsController.text.trim()
              );

              String mensaje;
              if(isNew)
              {
                mensaje="Added item '${passedInData.name}'";
              }
              else
              {
                mensaje="Updated item '${passedInData.name}'";
              }
              Navigator.of(context).pop(
                  mensaje
              );
            }

          },
          )
        )

      ])




    );
  }
}