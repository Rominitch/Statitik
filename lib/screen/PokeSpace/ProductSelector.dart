import 'package:flutter/material.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';

class ProductSelector extends StatefulWidget {
  final Language language;
  const ProductSelector(this.language, {Key? key}) : super(key: key);

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2,
      animationDuration: Duration.zero,
      initialIndex: 0,
      vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('PS_T0')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
                controller: tabController,
                //isScrollable: false,
                indicatorPadding: const EdgeInsets.all(1),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                tabs: [
                  Text(StatitikLocale.of(context).read('PS_B0')),
                  Text(StatitikLocale.of(context).read('PS_B1')),
                ]
            ),
            Expanded(
                child: TabBarView(
                  controller: tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Card(),
                    Card(),
                  ]
                )
            )
          ]
        ),
      ),
    );
  }
}
