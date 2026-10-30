import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        child: Row(
          children: [
            Column(
                children: [
                  Padding(
                  padding: EdgeInsets.all(8),
                  child: Image.network("https://picsum.photos/200/300"),),
              ],
            

           
          
        ),
        Column(
                children: [
                  Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Card",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )),
              ],
            

           
          
        ),
        ],
      ),
    ),);
  }
}
