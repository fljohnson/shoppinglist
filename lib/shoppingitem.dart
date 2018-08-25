
import 'storage.dart';

class ShoppingItem {
  int id=-1;
  num qty=1;
  num linetotal=0;
  String notes;
  String name;
  String fmtQty="1";
  String fmtTotal;



  ShoppingItem(String name, num total,{num qty=1,String details})
  {
    assert(name!=null && name.isNotEmpty); //theoretical double-bagging
    this.name = name;
    if(qty != null)
    {
      this.qty=qty;
      this.fmtQty=Storage.qtyFormatter.format(this.qty);
    }
    if(details != null) {
      notes = details;
    }

    this.linetotal= Storage.roundToPlaces(total,2);
    this.fmtTotal=Storage.moneyFormatter.format(this.linetotal);
    Storage.addShoppingItem(this);


  }

  ShoppingItem.fromFile(Map<String,dynamic> incoming)
  {
/*
    goods[j]["id"],
    goods[j]["name"],
    goods[j]["linetotal"],
    qty:goods[j]["qty"],
    details:goods[j]["notes"]
    */

    this.id = incoming["id"] as int;
    this.name = incoming["name"] as String;

      this.qty=incoming["qty"] as num;
      this.fmtQty=Storage.qtyFormatter.format(this.qty);

    //if(details != null) {
      notes = incoming["notes"] as String;
    //}

    //force to at most two decimal places
    this.linetotal = Storage.roundToPlaces(incoming["linetotal"] as num,2);

    this.fmtTotal=Storage.moneyFormatter.format(this.linetotal);
  }

  ShoppingItem.createBlank()
  {
    this.name = "";
    this.qty=0;
    this.fmtQty="";
    this.notes="";
    this.id=-1;
    this.linetotal=0;
    this.fmtTotal=" ";
  }

  _commit() async {
    //store this object in DB
    String rv;

    try {
      if (id == -1) {
        rv = await Storage.addShoppingItem(this) as String;
      }
      else {
        rv = await Storage.updateShoppingItem(this) as String;
      }
    }
    catch(uhoh)
    {
      rv= uhoh.toString();
    }
    return rv;
  }
  update({qty:String,name:String,total:String, details:String}) async
  {

    if(name!=null && name.isNotEmpty) {
      if (name != this.name) {
        this.name = name;
      }
    }
    else {
      //no good! mark the error and get out of here
      return "Item name cannot be blank";
    }
    var goodqty=num.tryParse(qty);
    if(goodqty != null)
    {
      this.qty = goodqty;
      this.fmtQty=Storage.qtyFormatter.format(this.qty);
    }
    if(details != null && details.isNotEmpty)
    {
      this.notes = details;
    }

    var goodtotal=num.tryParse(total);
    if(goodtotal != null)
    {

      this.linetotal=Storage.roundToPlaces(goodtotal,2);

      this.fmtTotal=Storage.moneyFormatter.format(this.linetotal);
    }
    var result = await _commit() as String;

    var rv;
    if(result == "OK")
    {
      return result;
    }
    var placeOfUserErr = result.indexOf("USER:");
    if( placeOfUserErr > -1)
    {
      rv = result.substring(placeOfUserErr + 5);
    }
    else
    {
      rv = "Error:$result\n-from new ShoppingItem ${this.name}";
    }

    return rv;
  }

  static String moneyFmt(num subject)
  {
    return Storage.moneyFormatter.format(subject);
  }
}