import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "shoppinglist.dart";
import "shoppingitem.dart";

final msgNoList = "No list exists";

_SampleAppPageState boss;
List<ShoppingItem> mayhemArray=[];
List<String> shoppinglists = [];
ShoppingItem passedInData;
ShoppingList currentlist;
String runningTotal="\$0.00";
bool built=false;
List<Widget> truewidgets = [];
String currentListName;
String failure;

Key gochakey;
Key totalkey;
Key mainbody;
Key currentlistlabel;
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

  askFirstList()
  {
    shoppinglists = ShoppingList.existingListNames;
    Object gotem =  Navigator.of(context).pushNamed("/list") as String;
    if(gotem!=null) {
      //create a list (this adds it to the set

      currentlist = ShoppingList(gotem);
      currentlist.checkResult();
      if(ShoppingList.completed == null)
      {
        built=false;
        ShoppingList.listNames.clear();
        mayhemArray.clear();
      }
      else
      {
        DlgUtil.doAlertDialog(context, ShoppingList.completed, ['OK']);
      }
    }
  }

  populateShoppingList() async {
    var toAdd = await currentlist.getList();
    mayhemArray.addAll(toAdd);
  }
  @override
  Widget build(BuildContext context) {
    boss=this;
    gochakey = new Key("really");
    totalkey = new Key("runningtotal");
    mainbody = new Key("hull");
    currentlistlabel =new Key("listlabel");
    gridstyle = new TextStyle(fontSize: 18.0);
    if(ShoppingList.isReady())
      {

        if (ShoppingList.getMostRecentListName() != null) {
          if (currentlist == null) {
            //currentlist=new ShoppingList("Untitled");
            getTheTop();
            mayhemArray.clear();
          }
          if (mayhemArray.isEmpty) {
            //mayhemArray.addAll(["A","B","C","D","E"]);
            if(currentlist != null) {

            //  populateShoppingList();
            }
            if(ShoppingList.completed != null)
            {
              failure = ShoppingList.completed;
            }
          }
        }
      }


    assert(failure == null,failure.toString());

    gatherData();
    biggerTyme(); //mangles truewidgets

    return Scaffold(
      appBar: AppBar(
        title: Text("Sample App"),
      ),
      //body: ListView(children: _getListData()),

      body:Column(children: truewidgets)
    );

  }


  biggerTyme()
  {
      try {
        print("begin bigTyme");
        bigTyme(truewidgets);
        print("end bigTyme");
      }
      catch(ecch)
      {
        print(ecch.toString());
      }

    return truewidgets;
  }

  getTheTop() async{
    currentlist = await ShoppingList.getMostRecentList();
  }

  getHeader(){
    String usableListName = msgNoList;
    TextStyle listNameStyle = TextStyle(fontSize: 18.0,color: Colors.red);
    if(currentlist!=null)
    {
      usableListName = currentlist.name;
      listNameStyle = TextStyle(fontSize: 18.0,);
    }

    var rv = (new Expanded(
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
                child: new Text(usableListName, style:listNameStyle,key:currentlistlabel),
              ),
            ),

            new Expanded(
                flex:0,
                child: Container (
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(vertical:8.0),
                  child: new CupertinoButton(
                    child:new Text("Change", style:TextStyle(color: Colors.blue)),
                    color:Colors.black12,
                    padding:EdgeInsets.all(8.0),

                  onPressed: () async
                  {
                    failure =  null;
                    //shoppinglists = await ShoppingList.existingListNames;
                    if(ShoppingList.completed != null)
                    {
                      setState((){
                        failure = ShoppingList.completed;
                      });
                      return;
                    }
                    built=true; //entering a "dialog"
                    Object gotem = await Navigator.of(context).pushNamed("/list") as String;
                    if(gotem!=null)
                    {
                      //prime gatherData()...
                      currentListName = gotem;
                      built = false;
                      //..and launch that pinball
                      boss.setState((){

                      });



                    }
                  }
                )

                  ,
                )
            )
            ,

            new Spacer(flex: 1)
            ,

            new Expanded(
                flex:0,
              child: Container (
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(vertical:8.0),
                child:new Text("Pre-tax Total: "+runningTotal,key:totalkey)
              )
            )

          ],
        ))
    )
    ;
    return rv;
  }

  updateUI() {

    String usableListName = msgNoList;
    TextStyle listNameStyle = TextStyle(fontSize: 18.0,color: Colors.red);
    if(currentlist!=null)
    {
      usableListName = currentlist.name;
      listNameStyle = TextStyle(fontSize: 18.0,);
    }

    new Text(usableListName, style:listNameStyle,key:currentlistlabel);

  }

  //centralized for multiple potential callers
  editItem(listItem) async {
    passedInData=listItem;
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
  }

  //let's get dirty
  gatherData() async {
    if(built)
      {
        if(currentListName != null)
        {
          print("bailing with $currentListName");
        }
        else
          {
            print("bailing with no input");
          }
        return;
      }
    if(!ShoppingList.isReady()) {
      await ShoppingList.init();
    }

    if(currentListName != null)
    {
      print("running with $currentListName");
    }
    else
    {
      print("running with no input");
    }
    if(currentListName != null)
    {

      var listOrdinal = shoppinglists.indexOf(currentListName);

      if(listOrdinal > -1)
      {
        currentlist = await ShoppingList.getNthList(listOrdinal);
      }
      else{
        currentlist = await ShoppingList.newList(currentListName);
      }

      mayhemArray.clear();
      if(currentlist != null)
      {
        await ShoppingList.setMostRecentList(currentlist.id);
      }
      //shoppinglists = await ShoppingList.existingListNames;
      currentListName = null;

    }

    if(currentlist == null) {
      currentlist = await ShoppingList.getMostRecentList();
      mayhemArray.clear();
      print("flung HAI");
    }


    /* usableListName goes here*/
    failure = null;
    shoppinglists = await ShoppingList.existingListNames;
    if(ShoppingList.completed != null)
    {

      setState(() {
        failure = ShoppingList.completed;
      });
      return;
    }





    if(currentlist != null && mayhemArray.isEmpty){
      //mayhemArray.addAll(["A","B","C","D","E"]);
      var toAdd = await currentlist.getList();
      if(ShoppingList.completed != null)
      {
        setState(() {
          failure = ShoppingList.completed;
        });
        return;
      }
      mayhemArray.addAll(toAdd);

      runningTotal = currentlist.runningTotal;

    }
    //prevent an "oh poop" loop of calls by the outermost Widget
    built = true;
    //finally, if we have reason to update the visual after this, do so
    if(currentlist != null)
    {
      setState(() {
      });
    }
  }
  bigTyme(List<Widget> widgets)  {
    //List<Widget> widgets = [];
    List<Widget> listcontent = [];


    if(widgets.isNotEmpty)
    {
      //it sucks for memory management, but it works (FLJ,8/17/18)
      widgets.clear();
    }
if(currentListName != null)
  {
    print("starting header with $currentListName");
  }
  else
    {
      print("starting header with null");
    }

    try {
      widgets.add(getHeader());
    }
    catch(ecch)
    {
      print(ecch.toString());
    }
    if(currentListName != null)
    {
      print("finished header with $currentListName");
    }
    else
    {
      print("finished header with null");
    }


    if(ShoppingList.isReady()) {
      failure = null;
        listcontent =  _getListData(listcontent);

        if(failure == null) {
          widgets.add(new Expanded(
              flex: 7,
              child: ListView(key: gochakey, children: listcontent)
          )
          );
        }

    }
    if(shoppinglists.isEmpty)
    {
      /*
      setState(() {
        truewidgets = widgets;
      //  Column(key: mainbody, children: widgets);
        built=true;
      });*/
      //gotta love that "escape clause"
      return widgets;
    }
    widgets.add(new Row(
      children: <Widget>[
        new CupertinoButton(child: new Text("Add Item"),
        onPressed: () async {
          passedInData = ShoppingItem.createBlank();
          built = true;
          Object info = await Navigator.of(context).pushNamed("/item") as String;
          if(info != null)
          {
            //await DlgUtil.doAlertDialog(context,info,["OK"]);
            await currentlist.addItemByID(passedInData.id);
            if(ShoppingList.completed == null) {
              built = false;
              mayhemArray.clear(); //force a reload
              //runningTotal = currentlist.runningTotal;
              setState(() {
              });
            }
            else
            {
              setState(() {
                failure = ShoppingList.completed;
              });
            }


          }

        }
        )
      ],
    ));
    /*
    setState(() {
      truewidgets = widgets;
      //  Column(key: mainbody, children: widgets);
      built=true;
    });*/
    return widgets;
  }



  _getListData(List<Widget> widgets) {


    if(shoppinglists.isEmpty)
      {
        return widgets;
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
                    built = true;
                    Object gotem = await DlgUtil.doAlertDialog(context,"Remove item '${mayhemArray[i].name}' from what you're buying?",["Yes","No"]) as String;
                    if(gotem=="1")
                    {
                      await currentlist.removeItem(mayhemArray[i]);
                      if(ShoppingList.completed == null) {
                        built = false;
                        mayhemArray.clear(); //force a reload
                        //runningTotal = currentlist.runningTotal;
                        setState(() {
                        });
                      }
                      else
                      {
                        setState(() {
                          failure = ShoppingList.completed;
                        });
                      }
                      /*
                      setState((){
                        mayhemArray.clear(); //force a reload
                        runningTotal=currentlist.runningTotal;
                      });
                      */
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
      //change the flex factor for iOS. This was partially crowding the "minus" button on iPhone
      //(FLJ, 8/14/18)
      int flexForRemove=6;
      if(ios)
      {
        flexForRemove=5;
      }
      rowContent.addAll([
        new Expanded(
          flex:flexForRemove,
          child:GestureDetector(
      child:new Text(mayhemArray[i].name, style:gridstyle, textAlign: TextAlign.start,maxLines: 3,),
            onTap: () async {
              await editItem(mayhemArray[i]);
            },
          ),
        ),
        new Expanded(
          flex:3,
          child: GestureDetector(
            child: new Text(mayhemArray[i].fmtTotal, style:gridstyle,textAlign: TextAlign.center),
            onTap: () async {
              await editItem(mayhemArray[i]);
            },
          ),
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


      widgets.add(Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowContent,

        )
      ),

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
  String priorTotalVal =passedInData.fmtTotal.substring(1);
  TextField totalField;
  bool totalBusy = false;
  bool startedTotal = false;

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

  void selectAll(TextEditingController tango)
  {
    int farpoint=tango.text.length;
    if(farpoint>0)
      {
        tango.selection = TextSelection(baseOffset:0,extentOffset:farpoint);
      }
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
      totalController.text = priorTotalVal;
      var newqty=num.tryParse(qtyController.text);
      if(newqty == null)
        {
          newqty=0;
        }
      var priortotal=num.tryParse(totalController.text);
      if(priortotal == null || priortotal <0.01)
        {
          priortotal = passedInData.linetotal;
        }
      var
        shouldAsk =
            (newqty != priorqty);
      print("SHouldAsk:$shouldAsk $priorqty $newqty");
      shouldAsk =
          shouldAsk && (passedInData.id > -1 && priorqty == 0 && priortotal > 0);

      print("SHouldAsk:$shouldAsk");
      priorqty = newqty;

      var newtotal = ShoppingItem.moneyFmt(priortotal*newqty);

      if(shouldAsk) {
        Object gotem = await DlgUtil.doAlertDialog(context,
            "Is the correct total price now $newtotal?",
            ["Yes", "No"]) as String;
        if(gotem=="1")
        {
          totalController.text=newtotal.replaceAll("\$", "");
        }
      }


    });

    totalField = TextField(
      // style:gridstyle,

      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: totalController,
      decoration: InputDecoration(hintText: "Total Price"),
      //focusNode: new FocusNode(),


    );

    /*
    //TODO:note if first trigger
    totalField.focusNode.addListener((){
      /*
      var suspect=totalController.text;
      if(!totalField.focusNode.hasFocus)
      {

        //the user is actually out of the field (back button or done doesn't count)
        totalController.text = priorTotalVal;
        totalBusy = false;
        setState((){

        });
      }
      */
      if(totalField.focusNode.hasFocus)
      {
        if(startedTotal)
        {
          return;
        }

        startedTotal=true;
        selectAll(totalController);
      }
      else
      {
        startedTotal=false;
      }
    });
*/


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
          child:totalField,
        ),
        /*
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: new GestureDetector(

          ),

        ),
        */

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
          child: CupertinoButton(child:Text("Save"),onPressed: () async{
            //validate the input
            //obvious problem, and probably the only one:name is empty
            var possibleName=nameController.text.trim();
            var erreur; //pardon my French. We do it this way to allow for other possible errors
            if(possibleName.isEmpty)
            {
              erreur="Please enter a name for this item";
            }
            //did any part of the input fail muster?
            if(erreur != null)
            {
              //we have a problem, so tell the user
              DlgUtil.doAlertDialog(context,erreur,["OK"]);
              return; //get out of this function, so the user can try again
            }
            //create an Item object and add to ShoppingList
            var isNew = (passedInData.id == -1);

            if(passedInData != null) {
              var info = await passedInData.update(
                  qty: qtyController.text.trim(),
                  name: possibleName,
                  total: totalController.text.trim(),
                  details: detailsController.text.trim()
              ) as String;


              if(info == "OK"){

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
              else
              {

                if(info.startsWith("Error:")) {
                  //system-ish issue:so detonate
                  failure = info;

                  Navigator.of(context).pop(
                      null
                  );
                  return;
                }
                else
                {
                  //user input issue
                  DlgUtil.doAlertDialog(context, info, ['OK']);
                }

              }
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
  FixedExtentScrollController pickerController;
  int chosen=-1;
  List<Container> subPack = [];
  TextStyle gridstyle = new TextStyle(fontSize: 18.0);

  @override
  void dispose()
  {
    nameController.dispose();
    pickerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    List<GestureDetector> textPack = [];
    var count=shoppinglists.length;



    //find out the position of the currentlist in the set of lists
    if(chosen == -1) {
      if (count > 0) {
        var listN = shoppinglists.indexOf(currentlist.name);
        if (listN > -1) //this should always be the case, but...
            {
          chosen = listN;
        }
      }
      else
        {
          chosen = 0;
        }
    }

    subPack.clear();
    textPack.clear();

    for(int i=0;i<count;i++)
    {
      //textPack.add(new Text(shoppinglists[i]));
      subPack.add(new Container(
          color:(i==chosen)?Colors.black12:Colors.white,
          child:new Text(shoppinglists[i],style:gridstyle,textAlign: TextAlign.center),
        padding:EdgeInsets.symmetric(vertical: 8.0)
      ));
      textPack.add(
        new GestureDetector(
          onTap: () {
            setState((){
              chosen=i;
          });
        },
          child:subPack[i]
        )
      );
    }

    pickerController = FixedExtentScrollController(initialItem: chosen);
/*
    var picker = new CupertinoPicker(
      itemExtent:18.0,
      children:textPack,
      onSelectedItemChanged: (int value){
        chosen = value;
      },
      scrollController: pickerController,
    );*/
var picker=ListView(
  children:textPack
);
    var actions=<Widget>[];

    //if there are no preexisting lists, "Use Selected List" is not an option
    if(count>0)
    {
      actions.add(
          CupertinoButton(child:Text("Use Selected List"),onPressed: (){

            String mensaje;
            if(chosen > -1 && chosen < shoppinglists.length)
            {
              mensaje=shoppinglists[chosen];
            }

            Navigator.pop(context,mensaje);
          },
          )
      );
    }

    actions.add(
        CupertinoButton(child:Text("Make New"),onPressed: () async {

          String mensaje = nameController.text.trim();
          //input validation.
          var info;
          if(mensaje.isEmpty)
          {

            info="Please enter a name for the list";
          }
          if(info == null) {
            info = await ShoppingList.checkName(mensaje);
            if(info != null && info.toString().startsWith("Error:"))
            {

              Navigator.of(context).pop(
                  info.toString()
              );
              return;
            }

          }

          //if the input failed validation, say so, and have the user try again.
          if(info != null)
          {
            DlgUtil.doAlertDialog(context,info,["OK"]);
          }
          else
          {


            Navigator.of(context).pop(
                mensaje

            );

          }
        },
        )
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
              decoration: InputDecoration(hintText: "Enter a new list here"),
              maxLines: 1,

            ),
          ),
    ),


             Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
    children: actions,

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