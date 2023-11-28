import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:mars_photos/data/models/rover.dart';
import 'package:mars_photos/data/repo/repo.dart';
import 'package:mars_photos/ui/widgets/mars_photo_card.dart';

import '../../data/provider/mars_model.dart';
import '../../utils/constants.dart';
import '../widgets/home_drawer.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MarsModel(repo: Repo()),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.appTitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          drawer: const HomeDrawer(),
          body: HomeBody(),
          floatingActionButton: Consumer<MarsModel>(
            builder: (context, model, child) {
              return FloatingActionButton(onPressed: () {
                // model.initializeData();
                model.fetchRoverData();
                // print(model.isDataReady);
              });
            },
          ),
        ));
  }
}

class HomeBody extends StatelessWidget {
  final ScrollController scrollController = ScrollController();
  int pageCount = 0;

  void checkScrollPosition(DateTime earthDate){
    if(scrollController.offset >=
        scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange){
      pageCount++;
     
    }
  }

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      debugPrint('$scrollController');
    });
    final Rover? rover = Hive.box<Rover>(roverDetailsKey).get(roverDetails);

    return Consumer<MarsModel>(
      builder: (context, model, child) {
        return model.isDataReady
            ? Column(
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.date),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      // Fetch Rover data if not available in Hive
                   
                      if (rover == null) {
                        await model.fetchRoverData();
                      }
                      await model.pickDate(context, rover ?? model.rover!);
                    },
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      thickness: 10,
                      trackVisibility: true,
                      interactive: true,
                      child: ListView.builder(

                        controller: scrollController,
                        itemCount: model.photosList.length,
                        itemBuilder: (_, i) {
                          checkScrollPosition(model.photosList[i].earthDate);

                          return MarsPhotoCard(marsPhoto: model.photosList[i]);
                        },
                      ),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}
