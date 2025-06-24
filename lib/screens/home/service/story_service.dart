import '../model/story_model.dart';

class StoryService {
  Future<List<Story>> fetchStories() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Story(
        title: "Zawada's Story: How smart choices can shape your future.",
        description:
            "At just 19 Zawada from Morogoro was unsure of her future......",
        imageAsset: 'assets/zawada.png',
        buttonText: 'Continue',
      ),
      // Story(
      //   title: 'GBV Community',
      //   description: '',
      //   imageAsset: 'assets/gbvcommunity.png',
      // ),
    ];
  }
}
