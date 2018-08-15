import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "shoppinglist.dart";
import "shoppingitem.dart";

List<ShoppingItem> mayhemArray=[];
List<String> shoppinglists;
ShoppingItem passedInData;
ShoppingList currentlist;
String runningTotal="\$0.00";

Key gochakey;
Key totalkey;
void main() {
  runApp(SampleApp());
}


bool ios;
class SampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ios = Theme.of(context).platform == TargetPlatform.iOS;
    return MaterialApp(
      title: 'Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleAppPage(),
      routes: <String, WidgetBuilder> {
        '/item': (BuildContext context) => ItemPage(),
        '/list': (BuildContext context) => ListPage(),
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
  FixedExtentScrollController pickerController;
  @override
  Widget build(BuildContext context) {
    gochakey = new Key("really");
    totalkey = new Key("runningtotal");
    gridstyle = new TextStyle(fontSize: 18.0);
    ShoppingList.getMostRecentListName();
    if(currentlist == null)
    {
      //currentlist=new ShoppingList("Untitled");
      currentlist=ShoppingList.getNthList(0);
      mayhemArray.clear();
    }
    if(mayhemArray.isEmpty){
      //mayhemArray.addAll(["A","B","C","D","E"]);
      mayhemArray.addAll(currentlist.getList());
    }

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

    widgets.add(new Expanded(
      flex:1,
        child:new Row(

      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Expanded(
          flex:0,
          child:Container(
              alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(vertical:8.0),
              child:new Text("List:", style:TextStyle(fontSize: 18.0)),
            ),
        ),
        new Expanded(
          flex:6,
          child: Container (
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(vertical:8.0),
            child: new Text("${currentlist.name}", style:TextStyle(fontSize: 18.0,)),
            ),
        ),
        new Expanded(
          flex:0,
            child: new CupertinoButton(
              child:new Text("Change", style:TextStyle(color: Colors.blue)),
              color:Colors.black12,
              padding:EdgeInsets.all(8.0),
              onPressed: () async {
                shoppinglists = ShoppingList.existingListNames;
                Object gotem = await Navigator.of(context).pushNamed("/list") as String;
                if(gotem!=null)
                {
                  var listN=shoppinglists.indexOf(gotem);
                  if(listN != -1) {
                    currentlist = ShoppingList.getNthList(listN);
                  }
                  else
                    {
                      //create a list (this adds it to the set
                      currentlist = ShoppingList(gotem);

                      ShoppingList.listNames.clear();
                    }
                  setState((){
                    mayhemArray.clear(); //force a reload
                    runningTotal=currentlist.runningTotal;
                  });
                }
              },
            )
        )
        ,
        new Spacer(flex: 1),
        new Expanded(
          flex:0,
          child:new Text("Pre-tax Total: "+runningTotal,key:totalkey)
        )
      ],
    ))
    )
    ;

    widgets.add(new Expanded(
        flex:7,
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
            await DlgUtil.doAlertDialog(context,info,["OK"]);
            setState(()
            {
              mayhemArray.clear(); //force a reload
              currentlist.addItemByID(passedInData.id);
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
    shoppinglists = ShoppingList.existingListNames;
    if(currentlist == null)
      {
        //currentlist=new ShoppingList("Untitled");
        currentlist=ShoppingList.getNthList(0);
        mayhemArray.clear();
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
      int flexForRemove=6;
      if(ios)
        {
          flexForRemove=5;
        }
      if(mayhemArray[i].qty >0)
      {
        rowContent.add(
            new Expanded(
              flex:2,
                child: new FlatButton(
                  child:new Icon(CupertinoIcons.minus_circled),
                  onPressed: () async {
                    Object gotem = await DlgUtil.doAlertDialog(context,"Remove item '${mayhemArray[i].name}' from what you're buying?",["Yes","No"]) as String;
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
          new Spacer(
            flex:2
          )
          /*
            new Expanded(
              child: new FittedBox(
                fit: BoxFit.scaleDown, // make the logo will be tiny
                child: const FlutterLogo(),
              ),
            )
                */
        );
      }
      rowContent.addAll([
        new Expanded(
          flex:flexForRemove,
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
                await DlgUtil.doAlertDialog(context,info,["OK"]);
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
      )
      );
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

  num priorqty=passedInData.qty;

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
    qtyController.addListener(() async {
      var newqty=num.tryParse(qtyController.text);
      if(newqty != null && newqty != priorqty) {
        priorqty = newqty;
        var newtotal = passedInData.linetotal*newqty;
        Object gotem = await DlgUtil.doAlertDialog(context,
            "Is the correct total price now $newtotal?",
            ["Yes", "No"]) as String;
        if(gotem=="1")
        {
          totalController.text="$newtotal";
        }
      }


    });

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

class DlgUtil {

  static doAlertDialog(BuildContext context,String prompt,List<String> buttons)
  {
    List<Widget> actionPack = [];
    var count=buttons.length;
    assert(count > 0);
    for(var i=0;i<count;i++)
    {
      actionPack.add(
        new CupertinoDialogAction(
          child: new Text(buttons[i]),
          onPressed: () {
            var onefirst=i+1;
            Navigator.pop(context,"$onefirst");
          }
        )
        /*
        //good, but not iOS-y enough (FLJ, 8/13/18)
        new FlatButton(
          child: new Text(buttons[i]),
          onPressed: () {
            var onefirst=i+1;
            Navigator.pop(context,"$onefirst");
          },
        ),
        */
      );
    }
    return showDialog(context: context,
      builder: (BuildContext context) {
      return new CupertinoAlertDialog(
        content: new Text(prompt),
        actions: actionPack
      );
      /*
      // known to work, but not iOS-y enough (FLJ, 8/13/18)
        return new AlertDialog(
            content: new Text(prompt),
            actions: actionPack
        );
        */
      },
    );
  }




}

class ListPage extends StatefulWidget {
  ListPage({Key key}) : super(key: key);


  @override
  _ListPageState createState() => _ListPageState();

}

class _ListPageState extends State<ListPage> {
  final nameController= TextEditingController();
  int chosen=-1;
  @override
  void dispose()
  {
    nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    List<Widget> textPack = [];
    var count=shoppinglists.length;
    for(int i=0;i<count;i++)
    {
      textPack.add(new Text(shoppinglists[i]));
    }

    var picker = new CupertinoPicker(
      itemExtent:18.0,
      children:textPack,
      onSelectedItemChanged: (int value){
        chosen = value;
      },
    );
    return Scaffold(
        appBar: AppBar(
          title: Text("Which List?"),
        ),
        //body: ListView(children: _getListData()),
        //body: Column(children: [new Text(needed)])
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                    //padding: const EdgeInsets.symmetric(vertical: 5.0),

                      flex:3,
                      child: picker
                  )
          ,

              Expanded(
                //padding: const EdgeInsets.symmetric(vertical: 5.0),

                flex:0,
                child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: TextField(
              //style:gridstyle,
              controller: nameController,
              decoration: InputDecoration(hintText: "Or create a new one"),
              maxLines: 1,

            ),
          ),
    ),

             Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
    children: <Widget>[
      CupertinoButton(child:Text("Use Selected List"),onPressed: (){

        String mensaje;
        if(chosen > -1 && chosen < shoppinglists.length)
          {
            mensaje=shoppinglists[chosen];
          }
        Navigator.pop(context,mensaje);
      },
      ),
      CupertinoButton(child:Text("Make New"),onPressed: (){
        //TODO:validate the data, back off if not good, else create an Item object and add to ShoppingList
        String mensaje = nameController.text.trim();

        Navigator.of(context).pop(
            mensaje
        );
      },
      )
    ],

    )

          )
,
              Spacer(
                flex: 6,
              )



        ])




    );
  }
}