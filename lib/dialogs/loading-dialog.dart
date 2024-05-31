import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        // The background color
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child:
                    // The loading indicator
                    //CircularProgressIndicator(),
                    LoadingAnimationWidget.discreteCircle(
                        color: Color(0xFFDEE8E8),
                        secondRingColor: Color(0xFFc1ea13),
                        thirdRingColor: Color(0xFF129fd6),
                        size: 50),
              ),
              SizedBox(
                height: 25,
              ),
              // Some text
              Center(child: Text('Espere un momento...')),
            ],
          ),
        ));
  }
}
