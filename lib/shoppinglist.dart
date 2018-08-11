import 'package:intl/intl.dart';

class ShoppingList {
  static List<String> get existingListNames {
    var rv=[];
    rv.add("hardware store");
    rv.add("WMT");
    rv.add("Taco fixings");
    //TODO:"select distinct(listName) from shoppinglist"
    return rv;
  }

  String name;
  String get runningTotal {
    var total=0.0;

    var formatter= new NumberFormat.simpleCurrency();
    //TODO:make that formatter static and accessible to Item and ShoppingList

    total+=10;
    //TODO:""select sum(item.rowTotal) as total from shoppinglist join item on itemId=item.id where listName = ? and qty>0"
    //first bound param is this.name

    return formatter.format(total);
  }

  //TODO: Item getItem(itemId)
  //"select * from item where id = ? and list_name = ?",arrayOf(itemId!!,this.name)

  List<String> getList()
  {
    return ["tomatoes","lettuce","cheddar","ground turkey","corn shells","tortillas"];
  }
  //TODO:List<Item> getList()
  /*
  "select * from item where id in (select itemId from shoppinglist where listName = ?)",
  arrayOf(this.name)
  */
  addItem(int itemID)
  {
    //TODO:"insert into shoppinglist values(this.name,itemID)"
  }
}