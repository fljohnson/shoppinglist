import 'package:intl/intl.dart';
import 'shoppingitem.dart';
class Storage {

  static NumberFormat moneyFormatter= new NumberFormat.simpleCurrency();
  static NumberFormat qtyFormatter = new NumberFormat("####.##");

  static Map<num, ShoppingItem> allItems = new Map();
  static addShoppingItem(ShoppingItem incoming){
    assert(incoming != null);
    var truid=allItems.length+1;
    //TODO:set truid to result of DB insert
    incoming.id=truid;
    allItems[truid]=incoming;
  }

  static updateShoppingItem(ShoppingItem incoming) {
    //TODO:DB update
  }
  static List<ShoppingItem> getListItems() {
    List<ShoppingItem> rv=new List();
    //TODO:add parameter for listID
    var itemIds=allItems.keys.toList();
    var totalcount=itemIds.length;
    for(num i=0;i<totalcount;i++)
    {
      var proto=allItems[itemIds[i]];
      //TODO:the real deal calls the ShoppingItem constructor that assigns an ID
      rv.add(proto);
    }
    return rv;
  }
}