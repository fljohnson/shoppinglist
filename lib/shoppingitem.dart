
import 'storage.dart';

class ShoppingItem {
  num id=-1;
  num qty=1;
  num linetotal=0;
  String notes;
  String name;
  String fmtQty="1";
  String fmtTotal;



  ShoppingItem(String name, num total,{num qty=1,String details = null})
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
    this.linetotal=total;
    this.fmtTotal=Storage.moneyFormatter.format(this.linetotal);
    Storage.addShoppingItem(this);
    //TODO: store this object in DB
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

  update({qty:String,name:String,total:String, details:String})
  {
    if(name!=null && name.isNotEmpty) {
      if (name != this.name) {
        this.name = name;
      }
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
      this.linetotal=goodtotal;
      this.fmtTotal=Storage.moneyFormatter.format(this.linetotal);
    }
    if(id == -1)
    {
      Storage.addShoppingItem(this);
    }
    else
    {
      Storage.updateShoppingItem(this);
    }
  }

}