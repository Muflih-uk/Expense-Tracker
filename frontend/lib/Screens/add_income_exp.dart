import 'package:expense_tracker/Constants/app_color.dart';
import 'package:expense_tracker/Provider/category_provider.dart';
import 'package:expense_tracker/Screens/Widgets/add_inc_exp_wid.dart';
import 'package:expense_tracker/Screens/Widgets/app_widgets.dart';
import 'package:expense_tracker/Services/transcation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/Model/transaction_model.dart';
import 'package:expense_tracker/Provider/account_provider.dart';

class AddIncomeExp extends StatefulWidget {
  final String purpose;
  const AddIncomeExp({
    super.key,
    required this.purpose
  });
  @override
  State<AddIncomeExp> createState() => StateAddIncomeExp();
}

class StateAddIncomeExp extends State<AddIncomeExp> {

  @override
  void initState(){
    super.initState();
    Future.microtask(() =>
        Provider.of<CategoryProvider>(context, listen: false).fetchCategory());
  }

  void backPage(BuildContext context){
    Navigator.pushNamed(context, '/add_page');
  }

  // Service
  final TranscationService _service = TranscationService();


  // Text Controllers
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  final TextEditingController tagCtrl = TextEditingController();
  
  
  
  void onAdd(BuildContext context) async {
    final categoryId = Provider.of<CategoryProvider>(context, listen: false).selectedId;
    final accountId = Provider.of<AccountProvider>(context, listen: false).accountId;

    // Validation
    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Title and Amount are required"))
      );
      return;
    }

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a category"))
      );
      return;
    }

    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account not loaded or selected"))
      );
      return;
    }

    final newTransaction = TransactionModel(
      title: titleCtrl.text,
      amount: amountCtrl.text,
      transactionType: widget.purpose == 'Income' ? "income" : "expense",
      category: categoryId,
      account: accountId,
      date: DateTime.now(),
      notes: noteCtrl.text,
      tags: tagCtrl.text,
    );

    final bool isSuccess = await _service.postTransaction(newTransaction);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction Successful"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction Failed"))
      );
    }
  }



  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    tagCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColor.appPrimary,
      appBar: AppWidgets.topBar(
        context: context, 
        title: "Add ${widget.purpose}", 
        leftArrow: backPage
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 0,),
          
              // Income Title
              Text(
                "${widget.purpose} Title",
                style: TextStyle(
                  color: AppColor.placeHolderColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 2,),
              AddIncExpWidget.fieldBox(
                controller: titleCtrl,
                numKeyboard: false
              ),

              // Amount
              SizedBox(height: 10,),
              Text(
                "Amount",
                style: TextStyle(
                  color: AppColor.placeHolderColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 2,),
              AddIncExpWidget.fieldBox(
                controller: amountCtrl,
                numKeyboard: true
              ),

              // Notes
              SizedBox(height: 10,),
              Text(
                "Note",
                style: TextStyle(
                  color: AppColor.placeHolderColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 2,),
              AddIncExpWidget.fieldBox(
                controller: noteCtrl,
                numKeyboard: false
              ),

              // Tags
              SizedBox(height: 10,),
              Text(
                "Tags",
                style: TextStyle(
                  color: AppColor.placeHolderColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 2,),
              AddIncExpWidget.fieldBox(
                controller: tagCtrl,
                numKeyboard: false
              ),

              // Catogaries
              SizedBox(height: 10,),
              Text(
                "Category",
                style: TextStyle(
                  color: AppColor.placeHolderColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),

              Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.categories.isEmpty) {
                    return Center(child: Text("No categories available."));
                  }

                  return Column(
                    children: provider.categories.map((category) {
                      return RadioListTile<int>(
                        title: Text(category['title']),
                        value: category['id'],
                        groupValue: provider.selectedId,
                        onChanged: (value) {
                          if (value != null) {
                            provider.selectCategory(value);
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),


              // Add Button
              SizedBox(height: 0,),
              AddIncExpWidget.addButton(
                context: context,
                onSubmit: onAdd,
                typeTrans: "ADD ${widget.purpose.toUpperCase()}"
              )
            ],
          ),
        )
      )
    );
  }
}