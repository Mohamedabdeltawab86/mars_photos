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
  final DateTime? earthDate;
  // final ScrollController scrollController = ScrollController();
  int pageCount = 0;

  Home({super.key, this.earthDate});

  @override
  Widget build(BuildContext context) {
    final MarsModel model = Provider.of<MarsModel>(context, listen: false);
    model.resetHomePage();
    model.fetchRoverData();
    model.fetchMarsPhotos(earthDate);

    model.addListener(() {
      debugPrint('Home: ${model.isDataReady}');
      if (model.isDataReady) {
        model.checkScrollPosition(earthDate);
      }
    });

    final Rover? rover = Hive.box<Rover>(roverDetailsKey).get(roverDetails);

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
          body: Consumer<MarsModel>(
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

                            await model.pickDate(
                                context, rover ?? model.rover!);
                          },
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: model.scrollController,
                            thumbVisibility: true,
                            thickness: 10,
                            trackVisibility: true,
                            interactive: true,
                            child: ListView.builder(
                              controller: model.scrollController,
                              itemCount: model.photosList.length,
                              itemBuilder: (_, i) {
                                model.checkScrollPosition(
                                    model.photosList[i].earthDate);
                                model.fetchMarsPhotos(
                                    model.photosList[i].earthDate,
                                    page: pageCount++);

                                return MarsPhotoCard(
                                    marsPhoto: model.photosList[i]);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator());
            },
          ),
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
