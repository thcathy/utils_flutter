import 'package:flutter/material.dart';

abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title()),
        actions: buildActions(context),
        elevation: 2.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SelectionArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: buildBody(context)),
                      ],
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
      floatingActionButton: buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildBody(BuildContext context);

  Widget buildFloatingActionButton(BuildContext context) => Container();

  List<Widget> buildActions(BuildContext context) => [];

  String title() => 'Squote Utility';
}
