// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:mars_photos/data/models/mars_photo.dart';
import 'package:mars_photos/data/models/rover.dart';

import '../repo/repo.dart';

class MarsModel extends ChangeNotifier {
  final Repo repo;

  MarsModel({
    required this.repo,
  }) {
    fetchRoverData();
  }

  int pageCount = 1;

  List<MarsPhoto> photosList = [];

  bool isPhotosLoaded = false;

  Rover? rover;

  bool isDataReady = false;

  Future<void> fetchRoverData() async {
    try {
      isDataReady = await repo.fetchCuriosityData();
      // isDataReady = true;
      print("1111");
      print(isDataReady);
      notifyListeners();
    } catch (e) {
      debugPrint('Error is $e');
    }
  }

  Future<void> initializeData() async {
    isDataReady = await repo.fetchCuriosityData();
    // print(isDataReady);
    notifyListeners();
  }

  ScrollController? scrollController;
  void checkScrollPosition(DateTime earthDate) {
    if (scrollController!.offset >=
            scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      fetchMarsPhotos(earthDate, page: pageCount++);
    }
    notifyListeners();
  }

  void fetchMarsPhotos(DateTime? earthDate, {int? page}) async {
    final photos = earthDate != null
        ? await repo.fetchDatePhotos(earthDate)
        : await repo.fetchLatestPhotos();

    isPhotosLoaded = true;
    // print(photos);
    photosList.addAll(photos);
    notifyListeners();
  }

  void resetHomePage() {
    photosList = [];
    isPhotosLoaded = true;
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context, Rover rover) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: rover.maxDate,
      firstDate: rover.landingDate,
      lastDate: rover.maxDate,
    );
    if (date != null) {
      photosList = await repo.fetchDatePhotos(date);
      notifyListeners();
    }
  }
}
