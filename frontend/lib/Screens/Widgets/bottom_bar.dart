import 'package:expense_tracker/Constants/app_color.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColor.placeHolderColor, 
            width: 1.0,         
          ),
        ),
      ),
      child: BottomAppBar(
        height: 70,
        color: Colors.white, 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home_outlined,color: AppColor.placeHolderColor,size: 35,),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings,color: AppColor.placeHolderColor,size: 35,),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
