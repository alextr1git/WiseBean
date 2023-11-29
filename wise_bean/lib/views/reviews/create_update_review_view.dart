import 'package:flutter/material.dart';
import 'package:wise_bean/services/auth/auth_service.dart';
import 'package:wise_bean/services/crud/review_service.dart';
import 'package:wise_bean/utilities/generics/get_arguments.dart';

class CreateUpdateReviewView extends StatefulWidget {
  const CreateUpdateReviewView({super.key});

  @override
  State<CreateUpdateReviewView> createState() => _CreateUpdateReviewViewState();
}

class _CreateUpdateReviewViewState extends State<CreateUpdateReviewView> {
  DatabaseReview? _review;
  late final ReviewsService _reviewsService;
  late final TextEditingController _remarksTextController;
  bool _initialized = false;
  double _descriptionCorrectness = 3.0;
  double _balance = 3.0;
  double _enjoymnet = 3.0;
  double _totalRate = 3.0;
  final List<double> _sliderValuesRange = [1, 2, 3, 4, 4.5, 4.6, 4.8, 5];
  final Map<double, double> _matchMap = {
    0: 1.0,
    1: 2.0,
    2: 3.0,
    3: 4.0,
    4: 4.5,
    5: 4.6,
    6: 4.8,
    7: 5.0,
  };

  void initReview(BuildContext context) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    final existingReview = _review;
    if (existingReview != null) {
      return;
    }
    final widgetReview = context.getArgument<DatabaseReview>();
    if (widgetReview != null) {
      _review = widgetReview;
      _remarksTextController.text = widgetReview.remarks;
      _balance = convertToSliderValue(widgetReview.balance);
      _descriptionCorrectness =
          convertToSliderValue(widgetReview.descriptionCorrectness);
      _enjoymnet = convertToSliderValue(widgetReview.enjoyment);
      _totalRate = widgetReview.totalRate;
      return;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final owner = await _reviewsService.getUser(email: email);
    final newReview = await _reviewsService.createReview(
        balance: _balance,
        descriptionCorrectness: _descriptionCorrectness,
        totalRate: _totalRate,
        enjoyment: _enjoymnet,
        remarks: _remarksTextController.text,
        owner: owner);
    _review = newReview;
    return;
  }

  Future<bool> _saveReviewIfNotEmpty() async {
    final review = _review;
    final remarks = _remarksTextController.text;
    final balance = convertToRealValue(_balance);
    final descriptionCorrectness = convertToRealValue(_descriptionCorrectness);
    final totalRate = _totalRate;
    final enjoyment = convertToRealValue(_enjoymnet);
    if (review != null) {
      await _reviewsService.updateReview(
        review: review,
        remarks: remarks,
        balance: balance,
        enjoyment: enjoyment,
        descriptionCorrectness: descriptionCorrectness,
        totalRate: totalRate,
      );
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _reviewsService = ReviewsService();
    _remarksTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _remarksTextController.dispose();
    _initialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initReview(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('New review'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text('Rate the correcteness of description')]),
              Slider(
                value: _balance,
                onChanged: (newBalance) {
                  setState(() {
                    _balance = newBalance;
                    recalculateTotalRate();
                  });
                },
                divisions: 7,
                label: _sliderValuesRange[_balance.round()].toString(),
                min: 0,
                max: 7,
              ),
              if (_balance == 0)
                const Text('Unbalanced as fuck')
              else if (_balance == 1)
                const Text('Very unbalanced')
              else if (_balance == 2)
                const Text('Medium balanced')
              else if (_balance == 3)
                const Text('Pretty balanced')
              else if (_balance == 4)
                const Text('Really balanced')
              else if (_balance == 5)
                const Text('Amazingly balanced')
              else if (_balance == 6)
                const Text('Almost perfectly balanced')
              else if (_balance == 7)
                const Text('Absolute piece of art in balance')
              else
                Text("$_balance"),
              const SizedBox(
                height: 20,
              ),
              const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text('Rate the correcteness of description')]),
              Slider(
                value: _descriptionCorrectness,
                onChanged: (newDescriptionCorrectness) {
                  setState(() {
                    _descriptionCorrectness = newDescriptionCorrectness;
                    recalculateTotalRate();
                  });
                },
                divisions: 7,
                label: _sliderValuesRange[_descriptionCorrectness.round()]
                    .toString(),
                min: 0,
                max: 7,
              ),
              if (_descriptionCorrectness == 0)
                const Text('They say black is white')
              else if (_descriptionCorrectness == 1)
                const Text('Not even close')
              else if (_descriptionCorrectness == 2)
                const Text('Only few mathches')
              else if (_descriptionCorrectness == 3)
                const Text('Seems to be ')
              else if (_descriptionCorrectness == 4)
                const Text('Pretty close')
              else if (_descriptionCorrectness == 5)
                const Text('Amazingly close')
              else if (_descriptionCorrectness == 6)
                const Text('Almost everything feels perfect')
              else if (_descriptionCorrectness == 7)
                const Text('Every descriptor is feeled perfectly')
              else
                Text("$_descriptionCorrectness"),
              const SizedBox(
                height: 20,
              ),
              const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text('Rate your enjoyment')]),
              Slider(
                value: _enjoymnet,
                onChanged: (newEnjoyment) {
                  setState(() {
                    _enjoymnet = newEnjoyment;
                    recalculateTotalRate();
                  });
                },
                divisions: 7,
                label: _sliderValuesRange[_enjoymnet.round()].toString(),
                min: 0,
                max: 7,
              ),
              if (_enjoymnet == 0)
                const Text('I hate it!')
              else if (_enjoymnet == 1)
                const Text('I do not like it!')
              else if (_enjoymnet == 2)
                const Text('Ahh, average!')
              else if (_enjoymnet == 3)
                const Text('It was a pleasure!')
              else if (_enjoymnet == 4)
                const Text('It was amazing!')
              else if (_enjoymnet == 5)
                const Text('It was a bit more than amazing')
              else if (_enjoymnet == 6)
                const Text('Almost perfect!')
              else if (_enjoymnet == 7)
                const Text('Totally perfect!')
              else
                Text("$_enjoymnet"),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Total rating is $_totalRate",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: _remarksTextController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Type your remarks here...'),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _saveReviewIfNotEmpty();
                  },
                  child: const Text('Save review'))
            ],
          ),
        ));
  }

  double convertToRealValue(double fakeValue) {
    return _matchMap[fakeValue] ?? 3.0;
  }

  double convertToSliderValue(double realValue) {
    return _matchMap.keys.firstWhere((k) => _matchMap[k] == realValue);
  }

  void recalculateTotalRate() {
    double notRoundedRate = (convertToRealValue(_descriptionCorrectness) +
            convertToRealValue(_balance) +
            convertToRealValue(_enjoymnet)) /
        3;
    _totalRate = double.parse(notRoundedRate.toStringAsFixed(1));
  }
}
